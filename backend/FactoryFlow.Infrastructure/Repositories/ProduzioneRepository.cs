using System.Data;
using System.Text.Json;
using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Configurazione;
using FactoryFlow.Core.Models.Operatori;
using FactoryFlow.Core.Models.Produzione;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace FactoryFlow.Infrastructure.Repositories;

public sealed class ProduzioneRepository : IProduzioneRepository
{
    private readonly string _adHocConnectionString;
    private readonly string _farmFlowConnectionString;
    private readonly int _esercizioDefault;

    public ProduzioneRepository(IConfiguration configuration)
    {
        _adHocConnectionString = configuration.GetConnectionString("AdhocConnection")
            ?? configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string AdhocConnection mancante.");

        _farmFlowConnectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");

        _esercizioDefault = int.TryParse(configuration["AdHoc:Esercizio"], out var esercizio)
            ? esercizio
            : DateTime.Today.Year;
    }

    public async Task<List<ArticoloProduzioneDto>> GetArticoliAsync(CancellationToken ct = default)
    {
        var config = await GetConfigAsync(ct);
        var result = new List<ArticoloProduzioneDto>();
        var artIcol = TableName(config.PrefissoAzienda, "ART_ICOL");

        await using var conn = new SqlConnection(_adHocConnectionString);
        await using var cmd = new SqlCommand($@"
            SELECT
                LTRIM(RTRIM(ARCODART)) AS CodArticolo,
                LTRIM(RTRIM(ARDESART)) AS Descrizione,
                LTRIM(RTRIM(ISNULL(ARUNMIS1, ''))) AS UnitaMisura,
                LTRIM(RTRIM(ARCODDIS)) AS CodiceDistinta,
                CAST(CASE WHEN ISNULL(ARFLLOTT, '') = 'S' THEN 1 ELSE 0 END AS bit) AS GestioneLotti
            FROM {artIcol}
            WHERE ISNULL(LTRIM(RTRIM(ARCODDIS)), '') <> ''
            ORDER BY ARCODART;", conn);

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);

        while (await reader.ReadAsync(ct))
        {
            result.Add(ReadArticolo(reader));
        }

        return result;
    }

    public async Task<DistintaProduzioneDto?> GetDistintaAsync(
        string codArticolo,
        decimal quantita,
        CancellationToken ct = default)
    {
        var config = await GetConfigAsync(ct);
        var artIcol = TableName(config.PrefissoAzienda, "ART_ICOL");
        var distBase = TableName(config.PrefissoAzienda, "DISTBASE");

        await using var conn = new SqlConnection(_adHocConnectionString);
        await using var cmd = new SqlCommand($@"
            DECLARE @CodDistinta varchar(20);

            SELECT @CodDistinta = LTRIM(RTRIM(ARCODDIS))
            FROM {artIcol}
            WHERE LTRIM(RTRIM(ARCODART)) = LTRIM(RTRIM(@CodArticolo))
              AND ISNULL(LTRIM(RTRIM(ARCODDIS)), '') <> '';

            SELECT
                LTRIM(RTRIM(COALESCE(NULLIF(D.DBARTCOM, ''), NULLIF(D.DBCODCOM, '')))) AS CodComponente,
                LTRIM(RTRIM(COALESCE(NULLIF(D.DBDESARTDISC, ''), NULLIF(A.ARDESART, ''), NULLIF(D.DBDESCOM, ''), ''))) AS Descrizione,
                LTRIM(RTRIM(COALESCE(NULLIF(D.DBUNMISURADIS, ''), NULLIF(D.DBUNIMIS, ''), NULLIF(A.ARUNMIS1, ''), ''))) AS UnitaMisura,
                Q.QuantitaDistinta,
                Q.QuantitaDistinta * @Quantita AS QuantitaProposta,
                Q.QuantitaDistinta * @Quantita AS QuantitaDaScaricare,
                COALESCE(NULLIF(LTRIM(RTRIM(D.DBCODMAG)), ''), @MagazzinoDefault) AS Magazzino,
                CAST(CASE WHEN ISNULL(A.ARFLLOTT, '') = 'S' THEN 1 ELSE 0 END AS bit) AS GestioneLotti
            FROM {distBase} D
            CROSS APPLY
            (
                SELECT CAST(
                    CASE
                        WHEN ISNULL(D.DBQTADISCARICA, 0) <> 0 THEN D.DBQTADISCARICA
                        WHEN ISNULL(D.DBQTADIS, 0) <> 0 THEN D.DBQTADIS
                        ELSE ISNULL(D.DBQTAMOV, 0)
                    END AS decimal(18, 6)
                ) AS QuantitaDistinta
            ) Q
            LEFT JOIN {artIcol} A
              ON LTRIM(RTRIM(A.ARCODART)) = LTRIM(RTRIM(COALESCE(NULLIF(D.DBARTCOM, ''), NULLIF(D.DBCODCOM, ''))))
            WHERE LTRIM(RTRIM(D.DBCODICE)) = LTRIM(RTRIM(@CodDistinta))
            ORDER BY D.CPROWORD, D.CPROWNUM;", conn);

        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = codArticolo.Trim();
        cmd.Parameters.Add("@Quantita", SqlDbType.Decimal).Value = quantita;
        cmd.Parameters["@Quantita"].Precision = 18;
        cmd.Parameters["@Quantita"].Scale = 6;
        cmd.Parameters.Add("@MagazzinoDefault", SqlDbType.VarChar, 5).Value = config.MagazzinoComponentiDefault;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);

        DistintaProduzioneDto? result = null;

        while (await reader.ReadAsync(ct))
        {
            result ??= new DistintaProduzioneDto
            {
                CodArticolo = codArticolo.Trim(),
                QuantitaProdotta = quantita
            };

            result.Componenti.Add(new ComponenteDistintaDto
            {
                CodComponente = GetString(reader, "CodComponente"),
                Descrizione = GetString(reader, "Descrizione"),
                UnitaMisura = GetString(reader, "UnitaMisura"),
                QuantitaDistinta = GetDecimal(reader, "QuantitaDistinta"),
                QuantitaProposta = GetDecimal(reader, "QuantitaProposta"),
                QuantitaDaScaricare = GetDecimal(reader, "QuantitaDaScaricare"),
                Magazzino = GetString(reader, "Magazzino"),
                GestioneLotti = GetBool(reader, "GestioneLotti")
            });
        }

        return result;
    }

    public async Task<ProduttivitaArticoloDto> GetProduttivitaArticoloAsync(
        string codArticolo,
        int? idLinea,
        CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            ;WITH Produttivita AS
            (
                SELECT
                    CodArticoloPF,
                    IdLinea,
                    DataProduzione,
                    CAST(QuantitaProdotta * 60.0 / NULLIF(DATEDIFF(second, OraInizioProduzione, OraFineProduzione), 0) AS decimal(18,6)) AS QuantitaMinuto
                FROM dbo.FF_DICHIARAZIONI_PRODUZIONE
                WHERE Stato = 'CONFERMATA'
                  AND LTRIM(RTRIM(CodArticoloPF)) = LTRIM(RTRIM(@CodArticolo))
                  AND OraInizioProduzione IS NOT NULL
                  AND OraFineProduzione IS NOT NULL
                  AND OraFineProduzione > OraInizioProduzione
                  AND QuantitaProdotta > 0
                  AND (@IdLinea IS NULL OR IdLinea = @IdLinea)
            )
            SELECT
                CAST(AVG(QuantitaMinuto) AS decimal(18,6)) AS MediaQuantitaMinuto,
                COUNT(1) AS NumeroDichiarazioni,
                MAX(DataProduzione) AS UltimaRilevazione
            FROM Produttivita;
            """, conn);
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = codArticolo.Trim();
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = idLinea.HasValue ? idLinea.Value : DBNull.Value;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        if (!await reader.ReadAsync(ct))
        {
            return new ProduttivitaArticoloDto
            {
                CodArticolo = codArticolo.Trim(),
                IdLinea = idLinea
            };
        }

        return new ProduttivitaArticoloDto
        {
            CodArticolo = codArticolo.Trim(),
            IdLinea = idLinea,
            MediaQuantitaMinuto = GetNullableDecimal(reader, "MediaQuantitaMinuto"),
            NumeroDichiarazioni = reader["NumeroDichiarazioni"] == DBNull.Value ? 0 : Convert.ToInt32(reader["NumeroDichiarazioni"]),
            UltimaRilevazione = GetNullableDate(reader, "UltimaRilevazione")
        };
    }
    public async Task<List<LottoProduzioneDto>> GetLottiAsync(
        string codArticolo,
        string magazzino,
        DateTime dataProduzione,
        CancellationToken ct = default)
    {
        var config = await GetConfigAsync(ct);
        var result = new List<LottoProduzioneDto>();
        var saldiLot = TableName(config.PrefissoAzienda, "SALDILOT");
        var lottiArt = TableName(config.PrefissoAzienda, "LOTTIART");

        await using var conn = new SqlConnection(_adHocConnectionString);
        await using var cmd = new SqlCommand($@"
            SELECT
                LTRIM(RTRIM(S.SUCODLOT)) AS CodiceLotto,
                CAST(ISNULL(S.SUQTAPER, 0) - ISNULL(S.SUQTRPER, 0) AS decimal(18, 6)) AS Disponibilita,
                L.LODATSCA AS DataScadenza,
                LTRIM(RTRIM(S.SUCODMAG)) AS Magazzino
            FROM {saldiLot} S
            INNER JOIN {lottiArt} L
              ON LTRIM(RTRIM(L.LOCODART)) = LTRIM(RTRIM(S.SUCODART))
             AND LTRIM(RTRIM(L.LOCODICE)) = LTRIM(RTRIM(S.SUCODLOT))
            WHERE LTRIM(RTRIM(S.SUCODART)) = LTRIM(RTRIM(@CodArticolo))
              AND LTRIM(RTRIM(S.SUCODMAG)) = LTRIM(RTRIM(@Magazzino))
              AND (L.LODATSCA IS NULL OR L.LODATSCA > @DataProduzione)
            ORDER BY L.LODATSCA, S.SUCODLOT;", conn);

        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = codArticolo.Trim();
        cmd.Parameters.Add("@Magazzino", SqlDbType.VarChar, 5).Value = magazzino.Trim();
        cmd.Parameters.Add("@DataProduzione", SqlDbType.Date).Value = dataProduzione.Date;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);

        while (await reader.ReadAsync(ct))
        {
            result.Add(new LottoProduzioneDto
            {
                CodiceLotto = GetString(reader, "CodiceLotto"),
                Disponibilita = GetDecimal(reader, "Disponibilita"),
                DataScadenza = GetNullableDate(reader, "DataScadenza"),
                Magazzino = GetString(reader, "Magazzino")
            });
        }

        return result;
    }

    public async Task<DichiarazioneProduzioneResultDto> CreaDichiarazioneAsync(
        DichiarazioneProduzioneRequestDto request,
        CancellationToken ct = default)
    {
        var config = await GetConfigAsync(ct);

        if (request.DataProduzione.Date > DateTime.Today)
        {
            var prevista = new DichiarazioneProduzioneResultDto
            {
                Ok = true,
                Messaggio = "Dichiarazione prevista salvata. La registrazione AdHoc sara creata alla conferma."
            };
            await SalvaStoricoFactoryFlowAsync(config, request, prevista, "PREVISTA", "CREAZIONE_PREVISTA", ct);
            return prevista;
        }

        var result = await CreaDichiarazioneAdHocAsync(config, request, ct);
        await SalvaStoricoFactoryFlowAsync(config, request, result, "CONFERMATA", "CONFERMA_PRODUZIONE", ct);
        return result;
    }
    private async Task<DichiarazioneProduzioneResultDto> CreaDichiarazioneAdHocAsync(
        ConfigurazioneAttivaDto config,
        DichiarazioneProduzioneRequestDto request,
        CancellationToken ct)
    {
        await using var conn = new SqlConnection(_adHocConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FactoryFlow_CreaDichiarazioneProduzione", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        var esercizio = request.Esercizio > 0 ? request.Esercizio : _esercizioDefault;
        var magazzinoProdotto = string.IsNullOrWhiteSpace(request.MagazzinoProdotto)
            ? config.MagazzinoPFDefault
            : request.MagazzinoProdotto.Trim();

        var componenti = request.Componenti.Select(c => new
        {
            codice = c.Codice.Trim(),
            lotto = string.IsNullOrWhiteSpace(c.Lotto) ? null : c.Lotto.Trim(),
            magazzino = string.IsNullOrWhiteSpace(c.Magazzino)
                ? config.MagazzinoComponentiDefault
                : c.Magazzino.Trim(),
            quantita = c.Quantita
        });

        var componentiJson = JsonSerializer.Serialize(componenti);

        cmd.Parameters.Add("@CodAzi", SqlDbType.VarChar, 10).Value = config.CodAziAdhoc;
        cmd.Parameters.Add("@Esercizio", SqlDbType.Int).Value = esercizio;
        cmd.Parameters.Add("@DataRilevazione", SqlDbType.Date).Value = request.DataProduzione.Date;
        cmd.Parameters.Add("@ArticoloProdotto", SqlDbType.VarChar, 20).Value = request.ArticoloProdotto.Trim();
        cmd.Parameters.Add("@LottoProdotto", SqlDbType.VarChar, 20).Value = request.LottoProdotto.Trim();
        cmd.Parameters.Add("@MagazzinoProdotto", SqlDbType.VarChar, 5).Value = magazzinoProdotto;
        cmd.Parameters.Add("@QuantitaProdotta", SqlDbType.Decimal).Value = request.QuantitaProdotta;
        cmd.Parameters["@QuantitaProdotta"].Precision = 18;
        cmd.Parameters["@QuantitaProdotta"].Scale = 3;
        cmd.Parameters.Add("@ComponentiJson", SqlDbType.NVarChar, -1).Value = componentiJson;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);

        if (!await reader.ReadAsync(ct))
        {
            return new DichiarazioneProduzioneResultDto
            {
                Ok = true,
                Messaggio = "Dichiarazione produzione confermata."
            };
        }

        var serialCarico = GetNullableString(reader, "SerialCarico");
        var numeroCarico = GetNullableInt(reader, "NumeroCarico");
        var serialScarico = GetNullableString(reader, "SerialScarico");
        var numeroScarico = GetNullableInt(reader, "NumeroScarico");

        return new DichiarazioneProduzioneResultDto
        {
            Ok = true,
            SerialCarico = serialCarico,
            NumeroCarico = numeroCarico,
            SerialScarico = serialScarico,
            NumeroScarico = numeroScarico,
            Messaggio = $"Dichiarazione produzione confermata. Carico {serialCarico}/{numeroCarico}, scarico {serialScarico}/{numeroScarico}."
        };
    }

    private async Task SalvaStoricoFactoryFlowAsync(
        ConfigurazioneAttivaDto config,
        DichiarazioneProduzioneRequestDto request,
        DichiarazioneProduzioneResultDto result,
        string stato,
        string tipoAudit,
        CancellationToken ct)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        try
        {
            await using var headerCmd = new SqlCommand("""
                INSERT INTO dbo.FF_DICHIARAZIONI_PRODUZIONE
                    (IdLinea, IdMacchina, CodAziAdhoc, DataProduzione, OraInizioProduzione, OraFineProduzione, CodArticoloPF, DescrizionePF, LottoPF, MagazzinoPF,
                     QuantitaProdotta, SerialeCaricoAdhoc, NumeroCaricoAdhoc, SerialeScaricoAdhoc, NumeroScaricoAdhoc,
                     Stato, UtenteCreazione)
                OUTPUT INSERTED.IdDichiarazione
                VALUES
                    (@IdLinea, @IdMacchina, @CodAziAdhoc, @DataProduzione, @OraInizioProduzione, @OraFineProduzione, @CodArticoloPF, @DescrizionePF, @LottoPF, @MagazzinoPF,
                     @QuantitaProdotta, @SerialeCaricoAdhoc, @NumeroCaricoAdhoc, @SerialeScaricoAdhoc, @NumeroScaricoAdhoc,
                     @Stato, @Utente);
                """, conn, (SqlTransaction)tx);

            headerCmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
            headerCmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
            headerCmd.Parameters.Add("@CodAziAdhoc", SqlDbType.VarChar, 10).Value = config.CodAziAdhoc;
            headerCmd.Parameters.Add("@DataProduzione", SqlDbType.Date).Value = request.DataProduzione.Date;
            headerCmd.Parameters.Add("@OraInizioProduzione", SqlDbType.DateTime2).Value = request.OraInizioProduzione.HasValue ? request.OraInizioProduzione.Value : DBNull.Value;
            headerCmd.Parameters.Add("@OraFineProduzione", SqlDbType.DateTime2).Value = request.OraFineProduzione.HasValue ? request.OraFineProduzione.Value : DBNull.Value;
            headerCmd.Parameters.Add("@CodArticoloPF", SqlDbType.VarChar, 20).Value = request.ArticoloProdotto.Trim();
            headerCmd.Parameters.Add("@DescrizionePF", SqlDbType.VarChar, 100).Value = DbValue(request.DescrizioneProdotto, 100);
            headerCmd.Parameters.Add("@LottoPF", SqlDbType.VarChar, 30).Value = DbValue(request.LottoProdotto, 30);
            headerCmd.Parameters.Add("@MagazzinoPF", SqlDbType.VarChar, 5).Value = string.IsNullOrWhiteSpace(request.MagazzinoProdotto) ? config.MagazzinoPFDefault : request.MagazzinoProdotto.Trim();
            headerCmd.Parameters.Add("@QuantitaProdotta", SqlDbType.Decimal).Value = request.QuantitaProdotta;
            headerCmd.Parameters["@QuantitaProdotta"].Precision = 18;
            headerCmd.Parameters["@QuantitaProdotta"].Scale = 3;
            headerCmd.Parameters.Add("@SerialeCaricoAdhoc", SqlDbType.VarChar, 10).Value = DbValue(result.SerialCarico, 10);
            headerCmd.Parameters.Add("@NumeroCaricoAdhoc", SqlDbType.Int).Value = result.NumeroCarico.HasValue ? result.NumeroCarico.Value : DBNull.Value;
            headerCmd.Parameters.Add("@SerialeScaricoAdhoc", SqlDbType.VarChar, 10).Value = DbValue(result.SerialScarico, 10);
            headerCmd.Parameters.Add("@NumeroScaricoAdhoc", SqlDbType.Int).Value = result.NumeroScarico.HasValue ? result.NumeroScarico.Value : DBNull.Value;
            headerCmd.Parameters.Add("@Stato", SqlDbType.VarChar, 20).Value = stato;
            headerCmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";

            var idDichiarazione = Convert.ToInt64(await headerCmd.ExecuteScalarAsync(ct));

            foreach (var componente in request.Componenti)
            {
                await using var rowCmd = new SqlCommand("""
                    INSERT INTO dbo.FF_DICHIARAZIONI_COMPONENTI
                        (IdDichiarazione, CodComponente, DescrizioneComponente, UnitaMisura,
                         QuantitaDistinta, QuantitaProposta, QuantitaEffettiva, Lotto, Magazzino,
                         CostoMedioPonderato, CostoTotaleRiga, UtenteCreazione)
                    VALUES
                        (@IdDichiarazione, @CodComponente, @DescrizioneComponente, @UnitaMisura,
                         @QuantitaDistinta, @QuantitaProposta, @QuantitaEffettiva, @Lotto, @Magazzino,
                         NULL, NULL, @Utente);
                    """, conn, (SqlTransaction)tx);

                rowCmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                rowCmd.Parameters.Add("@CodComponente", SqlDbType.VarChar, 20).Value = componente.Codice.Trim();
                rowCmd.Parameters.Add("@DescrizioneComponente", SqlDbType.VarChar, 100).Value = DbValue(componente.Descrizione, 100);
                rowCmd.Parameters.Add("@UnitaMisura", SqlDbType.VarChar, 5).Value = DbValue(componente.UnitaMisura, 5);
                AddNullableDecimal(rowCmd, "@QuantitaDistinta", componente.QuantitaDistinta);
                AddNullableDecimal(rowCmd, "@QuantitaProposta", componente.QuantitaProposta);
                rowCmd.Parameters.Add("@QuantitaEffettiva", SqlDbType.Decimal).Value = componente.Quantita;
                rowCmd.Parameters["@QuantitaEffettiva"].Precision = 18;
                rowCmd.Parameters["@QuantitaEffettiva"].Scale = 6;
                rowCmd.Parameters.Add("@Lotto", SqlDbType.VarChar, 30).Value = DbValue(componente.Lotto, 30);
                rowCmd.Parameters.Add("@Magazzino", SqlDbType.VarChar, 5).Value = string.IsNullOrWhiteSpace(componente.Magazzino) ? config.MagazzinoComponentiDefault : componente.Magazzino.Trim();
                rowCmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
                await rowCmd.ExecuteNonQueryAsync(ct);
            }

            await InsertDichiarazioneOperatoriAsync(conn, (SqlTransaction)tx, idDichiarazione, request.Operatori, ct);

            await using var auditCmd = new SqlCommand("""
                INSERT INTO dbo.FF_AUDIT_EVENTI (Entita, IdEntita, TipoEvento, Descrizione, Utente)
                VALUES ('FF_DICHIARAZIONI_PRODUZIONE', @IdEntita, @TipoEvento, @Descrizione, @Utente);
                """, conn, (SqlTransaction)tx);
            auditCmd.Parameters.Add("@IdEntita", SqlDbType.VarChar, 50).Value = idDichiarazione.ToString();
            auditCmd.Parameters.Add("@TipoEvento", SqlDbType.VarChar, 50).Value = tipoAudit;
            auditCmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, -1).Value = result.Messaggio;
            auditCmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
            await auditCmd.ExecuteNonQueryAsync(ct);

            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }

    public async Task<DichiarazioneProduzioneResultDto> ConfermaDichiarazionePrevistaAsync(
        long idDichiarazione,
        CancellationToken ct = default)
    {
        var dettaglio = await GetDichiarazioneAsync(idDichiarazione, ct)
            ?? throw new InvalidOperationException("Dichiarazione non trovata.");

        if (!string.Equals(dettaglio.Stato, "PREVISTA", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Solo una dichiarazione PREVISTA puo essere confermata.");

        if (!string.IsNullOrWhiteSpace(dettaglio.SerialeCaricoAdhoc) || !string.IsNullOrWhiteSpace(dettaglio.SerialeScaricoAdhoc))
            throw new InvalidOperationException("La dichiarazione risulta gia collegata ad AdHoc.");

        if (dettaglio.DataProduzione.Date != DateTime.Today)
            throw new InvalidOperationException("La dichiarazione PREVISTA puo essere confermata solo nel giorno previsto.");

        var request = new DichiarazioneProduzioneRequestDto
        {
            IdLinea = dettaglio.IdLinea,
            IdMacchina = dettaglio.IdMacchina,
            CodAzi = dettaglio.CodAziAdhoc,
            Esercizio = _esercizioDefault,
            DataProduzione = dettaglio.DataProduzione,
            OraInizioProduzione = dettaglio.OraInizioProduzione,
            OraFineProduzione = dettaglio.OraFineProduzione,
            ArticoloProdotto = dettaglio.CodArticoloPF,
            DescrizioneProdotto = dettaglio.DescrizionePF,
            LottoProdotto = dettaglio.LottoPF ?? "",
            MagazzinoProdotto = dettaglio.MagazzinoPF,
            QuantitaProdotta = dettaglio.QuantitaProdotta,
            Componenti = dettaglio.Componenti.Select(c => new DichiarazioneProduzioneComponenteDto
            {
                Codice = c.CodComponente,
                Descrizione = c.DescrizioneComponente,
                UnitaMisura = c.UnitaMisura,
                QuantitaDistinta = c.QuantitaDistinta,
                QuantitaProposta = c.QuantitaProposta,
                Lotto = c.Lotto,
                Magazzino = c.Magazzino,
                Quantita = c.QuantitaEffettiva
            }).ToList()
        };

        var config = await GetConfigAsync(ct);
        var result = await CreaDichiarazioneAdHocAsync(config, request, ct);

        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        try
        {
            await using var cmd = new SqlCommand("""
                UPDATE dbo.FF_DICHIARAZIONI_PRODUZIONE
                SET Stato = 'CONFERMATA',
                    SerialeCaricoAdhoc = @SerialeCaricoAdhoc,
                    NumeroCaricoAdhoc = @NumeroCaricoAdhoc,
                    SerialeScaricoAdhoc = @SerialeScaricoAdhoc,
                    NumeroScaricoAdhoc = @NumeroScaricoAdhoc,
                    DataModifica = GETDATE(),
                    UtenteModifica = @Utente
                WHERE IdDichiarazione = @IdDichiarazione
                  AND Stato = 'PREVISTA'
                  AND SerialeCaricoAdhoc IS NULL
                  AND SerialeScaricoAdhoc IS NULL;
                """, conn, (SqlTransaction)tx);
            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            cmd.Parameters.Add("@SerialeCaricoAdhoc", SqlDbType.VarChar, 10).Value = DbValue(result.SerialCarico, 10);
            cmd.Parameters.Add("@NumeroCaricoAdhoc", SqlDbType.Int).Value = result.NumeroCarico.HasValue ? result.NumeroCarico.Value : DBNull.Value;
            cmd.Parameters.Add("@SerialeScaricoAdhoc", SqlDbType.VarChar, 10).Value = DbValue(result.SerialScarico, 10);
            cmd.Parameters.Add("@NumeroScaricoAdhoc", SqlDbType.Int).Value = result.NumeroScarico.HasValue ? result.NumeroScarico.Value : DBNull.Value;
            cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
            var rows = await cmd.ExecuteNonQueryAsync(ct);
            if (rows != 1)
                throw new InvalidOperationException("Conferma previsione non riuscita.");

            await InsertAuditAsync(conn, (SqlTransaction)tx, idDichiarazione, "CONFERMA_PREVISTA", result.Messaggio, ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }

        return result;
    }

    public async Task<List<DichiarazioneCalendarioGiornoDto>> GetCalendarioDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default)
    {
        var result = new List<DichiarazioneCalendarioGiornoDto>();
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            SELECT DataProduzione, COUNT(*) AS NumeroDichiarazioni
            FROM dbo.FF_DICHIARAZIONI_PRODUZIONE
            WHERE DataProduzione >= @Dal AND DataProduzione <= @Al
            GROUP BY DataProduzione
            ORDER BY DataProduzione;
            """, conn);
        cmd.Parameters.Add("@Dal", SqlDbType.Date).Value = dal.Date;
        cmd.Parameters.Add("@Al", SqlDbType.Date).Value = al.Date;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            result.Add(new DichiarazioneCalendarioGiornoDto
            {
                DataProduzione = Convert.ToDateTime(reader["DataProduzione"]),
                NumeroDichiarazioni = Convert.ToInt32(reader["NumeroDichiarazioni"])
            });
        }

        return result;
    }

    public async Task<List<DichiarazioneStoricoDto>> GetDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default)
    {
        var result = new List<DichiarazioneStoricoDto>();
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            SELECT
                D.IdDichiarazione, D.IdLinea, L.CodLinea, L.NomeLinea, D.IdMacchina, MC.CodMacchina, MC.NomeMacchina, D.CodAziAdhoc,
                D.DataProduzione, D.OraInizioProduzione, D.OraFineProduzione, D.CodArticoloPF, D.DescrizionePF, D.LottoPF, D.MagazzinoPF,
                D.QuantitaProdotta, P.ProduttivitaMinuto, M.MediaProduttivitaMinuto,
                CASE
                    WHEN P.ProduttivitaMinuto IS NULL OR M.MediaProduttivitaMinuto IS NULL OR M.MediaProduttivitaMinuto = 0 THEN NULL
                    ELSE CAST(((P.ProduttivitaMinuto - M.MediaProduttivitaMinuto) / M.MediaProduttivitaMinuto) * 100.0 AS decimal(18,6))
                END AS ScostamentoProduttivitaPercentuale,
                D.SerialeCaricoAdhoc, D.NumeroCaricoAdhoc,
                D.SerialeScaricoAdhoc, D.NumeroScaricoAdhoc, D.Stato,
                D.DataCreazione, D.DataModifica
            FROM dbo.FF_DICHIARAZIONI_PRODUZIONE D
            LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = D.IdLinea
            LEFT JOIN dbo.FF_MACCHINE MC ON MC.IdMacchina = D.IdMacchina
            OUTER APPLY
            (
                SELECT CAST(
                    CASE
                        WHEN D.OraInizioProduzione IS NULL OR D.OraFineProduzione IS NULL OR D.OraFineProduzione <= D.OraInizioProduzione THEN NULL
                        ELSE D.QuantitaProdotta * 60.0 / NULLIF(DATEDIFF(second, D.OraInizioProduzione, D.OraFineProduzione), 0)
                    END AS decimal(18,6)
                ) AS ProduttivitaMinuto
            ) P
            OUTER APPLY
            (
                SELECT CAST(AVG(CAST(X.QuantitaProdotta * 60.0 / NULLIF(DATEDIFF(second, X.OraInizioProduzione, X.OraFineProduzione), 0) AS decimal(18,6))) AS decimal(18,6)) AS MediaProduttivitaMinuto
                FROM dbo.FF_DICHIARAZIONI_PRODUZIONE X
                WHERE X.Stato = 'CONFERMATA'
                  AND LTRIM(RTRIM(X.CodArticoloPF)) = LTRIM(RTRIM(D.CodArticoloPF))
                  AND X.OraInizioProduzione IS NOT NULL
                  AND X.OraFineProduzione IS NOT NULL
                  AND X.OraFineProduzione > X.OraInizioProduzione
                  AND X.QuantitaProdotta > 0
            ) M            WHERE D.DataProduzione >= @Dal AND D.DataProduzione <= @Al
            ORDER BY D.DataProduzione DESC, D.IdDichiarazione DESC;
            """, conn);
        cmd.Parameters.Add("@Dal", SqlDbType.Date).Value = dal.Date;
        cmd.Parameters.Add("@Al", SqlDbType.Date).Value = al.Date;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            result.Add(ReadDichiarazione(reader));

        return result;
    }

    public async Task<DichiarazioneStoricoDto?> GetDichiarazioneAsync(
        long idDichiarazione,
        CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await conn.OpenAsync(ct);

        DichiarazioneStoricoDto? result = null;
        await using (var cmd = new SqlCommand("""
            SELECT
                D.IdDichiarazione, D.IdLinea, L.CodLinea, L.NomeLinea, D.IdMacchina, MC.CodMacchina, MC.NomeMacchina, D.CodAziAdhoc,
                D.DataProduzione, D.OraInizioProduzione, D.OraFineProduzione, D.CodArticoloPF, D.DescrizionePF, D.LottoPF, D.MagazzinoPF,
                D.QuantitaProdotta, P.ProduttivitaMinuto, M.MediaProduttivitaMinuto,
                CASE
                    WHEN P.ProduttivitaMinuto IS NULL OR M.MediaProduttivitaMinuto IS NULL OR M.MediaProduttivitaMinuto = 0 THEN NULL
                    ELSE CAST(((P.ProduttivitaMinuto - M.MediaProduttivitaMinuto) / M.MediaProduttivitaMinuto) * 100.0 AS decimal(18,6))
                END AS ScostamentoProduttivitaPercentuale,
                D.SerialeCaricoAdhoc, D.NumeroCaricoAdhoc,
                D.SerialeScaricoAdhoc, D.NumeroScaricoAdhoc, D.Stato,
                D.DataCreazione, D.DataModifica
            FROM dbo.FF_DICHIARAZIONI_PRODUZIONE D
            LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = D.IdLinea
            LEFT JOIN dbo.FF_MACCHINE MC ON MC.IdMacchina = D.IdMacchina
            OUTER APPLY
            (
                SELECT CAST(
                    CASE
                        WHEN D.OraInizioProduzione IS NULL OR D.OraFineProduzione IS NULL OR D.OraFineProduzione <= D.OraInizioProduzione THEN NULL
                        ELSE D.QuantitaProdotta * 60.0 / NULLIF(DATEDIFF(second, D.OraInizioProduzione, D.OraFineProduzione), 0)
                    END AS decimal(18,6)
                ) AS ProduttivitaMinuto
            ) P
            OUTER APPLY
            (
                SELECT CAST(AVG(CAST(X.QuantitaProdotta * 60.0 / NULLIF(DATEDIFF(second, X.OraInizioProduzione, X.OraFineProduzione), 0) AS decimal(18,6))) AS decimal(18,6)) AS MediaProduttivitaMinuto
                FROM dbo.FF_DICHIARAZIONI_PRODUZIONE X
                WHERE X.Stato = 'CONFERMATA'
                  AND LTRIM(RTRIM(X.CodArticoloPF)) = LTRIM(RTRIM(D.CodArticoloPF))
                  AND X.OraInizioProduzione IS NOT NULL
                  AND X.OraFineProduzione IS NOT NULL
                  AND X.OraFineProduzione > X.OraInizioProduzione
                  AND X.QuantitaProdotta > 0
            ) M            WHERE D.IdDichiarazione = @IdDichiarazione;
            """, conn))
        {
            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
            if (await reader.ReadAsync(ct))
                result = ReadDichiarazione(reader);
        }

        if (result == null)
            return null;

        await using (var cmd = new SqlCommand("""
            SELECT
                IdRiga, CodComponente, DescrizioneComponente, UnitaMisura,
                QuantitaDistinta, QuantitaProposta, QuantitaEffettiva,
                Lotto, Magazzino
            FROM dbo.FF_DICHIARAZIONI_COMPONENTI
            WHERE IdDichiarazione = @IdDichiarazione
            ORDER BY IdRiga;
            """, conn))
        {
            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                result.Componenti.Add(ReadDichiarazioneComponente(reader));
        }

        await using (var cmd = new SqlCommand("""
            SELECT
                IdDichiarazioneOperatore, IdOperatore, IdRuoloOperativo,
                CodOperatoreSnapshot, NomeOperatoreSnapshot, RuoloSnapshot,
                OraInizio, OraFine, Note
            FROM dbo.FF_DICHIARAZIONI_OPERATORI
            WHERE IdDichiarazione = @IdDichiarazione
            ORDER BY IdDichiarazioneOperatore;
            """, conn))
        {
            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                result.Operatori.Add(ReadDichiarazioneOperatore(reader));
        }

        await EnrichGestioneLottiComponentiAsync(result.Componenti, ct);

        return result;
    }

    public async Task UpdateDichiarazioneStoricoAsync(
        long idDichiarazione,
        DichiarazioneStoricoUpdateDto request,
        CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        try
        {
            await using (var checkCmd = new SqlCommand("""
                IF NOT EXISTS (SELECT 1 FROM dbo.FF_DICHIARAZIONI_PRODUZIONE WHERE IdDichiarazione = @IdDichiarazione)
                    THROW 51001, 'Dichiarazione non trovata.', 1;
                IF EXISTS (SELECT 1 FROM dbo.FF_DICHIARAZIONI_PRODUZIONE WHERE IdDichiarazione = @IdDichiarazione AND Stato = 'ANNULLATA')
                    THROW 51002, 'Dichiarazione annullata non modificabile.', 1;
                """, conn, (SqlTransaction)tx))
            {
                checkCmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                await checkCmd.ExecuteNonQueryAsync(ct);
            }

            await SyncAdHocDichiarazioneAsync(idDichiarazione, request, ct);

            await using (var cmd = new SqlCommand("""
                UPDATE dbo.FF_DICHIARAZIONI_PRODUZIONE
                SET IdLinea = @IdLinea,
                    IdMacchina = @IdMacchina,
                    DataProduzione = @DataProduzione,
                    OraInizioProduzione = @OraInizioProduzione,
                    OraFineProduzione = @OraFineProduzione,
                    DescrizionePF = @DescrizionePF,
                    LottoPF = @LottoPF,
                    MagazzinoPF = @MagazzinoPF,
                    QuantitaProdotta = @QuantitaProdotta,
                    DataModifica = GETDATE(),
                    UtenteModifica = @Utente
                WHERE IdDichiarazione = @IdDichiarazione;
                """, conn, (SqlTransaction)tx))
            {
                cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
                cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
                cmd.Parameters.Add("@DataProduzione", SqlDbType.Date).Value = request.DataProduzione.Date;
                cmd.Parameters.Add("@OraInizioProduzione", SqlDbType.DateTime2).Value = request.OraInizioProduzione.HasValue ? request.OraInizioProduzione.Value : DBNull.Value;
                cmd.Parameters.Add("@OraFineProduzione", SqlDbType.DateTime2).Value = request.OraFineProduzione.HasValue ? request.OraFineProduzione.Value : DBNull.Value;
                cmd.Parameters.Add("@DescrizionePF", SqlDbType.VarChar, 100).Value = DbValue(request.DescrizionePF, 100);
                cmd.Parameters.Add("@LottoPF", SqlDbType.VarChar, 30).Value = DbValue(request.LottoPF, 30);
                cmd.Parameters.Add("@MagazzinoPF", SqlDbType.VarChar, 5).Value = request.MagazzinoPF.Trim();
                cmd.Parameters.Add("@QuantitaProdotta", SqlDbType.Decimal).Value = request.QuantitaProdotta;
                cmd.Parameters["@QuantitaProdotta"].Precision = 18;
                cmd.Parameters["@QuantitaProdotta"].Scale = 3;
                cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
                await cmd.ExecuteNonQueryAsync(ct);
            }

            await using (var cmd = new SqlCommand("DELETE FROM dbo.FF_DICHIARAZIONI_COMPONENTI WHERE IdDichiarazione = @IdDichiarazione;", conn, (SqlTransaction)tx))
            {
                cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                await cmd.ExecuteNonQueryAsync(ct);
            }

            foreach (var componente in request.Componenti)
            {
                await using var cmd = new SqlCommand("""
                    INSERT INTO dbo.FF_DICHIARAZIONI_COMPONENTI
                        (IdDichiarazione, CodComponente, DescrizioneComponente, UnitaMisura,
                         QuantitaDistinta, QuantitaProposta, QuantitaEffettiva, Lotto, Magazzino,
                         CostoMedioPonderato, CostoTotaleRiga, UtenteCreazione)
                    VALUES
                        (@IdDichiarazione, @CodComponente, @DescrizioneComponente, @UnitaMisura,
                         @QuantitaDistinta, @QuantitaProposta, @QuantitaEffettiva, @Lotto, @Magazzino,
                         NULL, NULL, @Utente);
                    """, conn, (SqlTransaction)tx);
                cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                cmd.Parameters.Add("@CodComponente", SqlDbType.VarChar, 20).Value = componente.CodComponente.Trim();
                cmd.Parameters.Add("@DescrizioneComponente", SqlDbType.VarChar, 100).Value = DbValue(componente.DescrizioneComponente, 100);
                cmd.Parameters.Add("@UnitaMisura", SqlDbType.VarChar, 5).Value = DbValue(componente.UnitaMisura, 5);
                AddNullableDecimal(cmd, "@QuantitaDistinta", componente.QuantitaDistinta);
                AddNullableDecimal(cmd, "@QuantitaProposta", componente.QuantitaProposta);
                cmd.Parameters.Add("@QuantitaEffettiva", SqlDbType.Decimal).Value = componente.QuantitaEffettiva;
                cmd.Parameters["@QuantitaEffettiva"].Precision = 18;
                cmd.Parameters["@QuantitaEffettiva"].Scale = 6;
                cmd.Parameters.Add("@Lotto", SqlDbType.VarChar, 30).Value = DbValue(componente.Lotto, 30);
                cmd.Parameters.Add("@Magazzino", SqlDbType.VarChar, 5).Value = componente.Magazzino.Trim();
                cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
                await cmd.ExecuteNonQueryAsync(ct);
            }

            await using (var cmd = new SqlCommand("DELETE FROM dbo.FF_DICHIARAZIONI_OPERATORI WHERE IdDichiarazione = @IdDichiarazione;", conn, (SqlTransaction)tx))
            {
                cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
                await cmd.ExecuteNonQueryAsync(ct);
            }

            await InsertDichiarazioneOperatoriAsync(conn, (SqlTransaction)tx, idDichiarazione, request.Operatori, ct);

            await InsertAuditAsync(conn, (SqlTransaction)tx, idDichiarazione, "MODIFICA_STORICO_DICHIARAZIONE", "Modifica snapshot FactoryFlow della dichiarazione.", ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }

    public async Task AnnullaDichiarazioneStoricoAsync(
        long idDichiarazione,
        CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);
        try
        {
            await CancellaAdHocDichiarazioneAsync(idDichiarazione, ct);

            await using var cmd = new SqlCommand("""
                UPDATE dbo.FF_DICHIARAZIONI_PRODUZIONE
                SET Stato = 'ANNULLATA',
                    DataModifica = GETDATE(),
                    UtenteModifica = @Utente
                WHERE IdDichiarazione = @IdDichiarazione
                  AND Stato <> 'ANNULLATA';
                """, conn, (SqlTransaction)tx);
            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
            await cmd.ExecuteNonQueryAsync(ct);

            await InsertAuditAsync(conn, (SqlTransaction)tx, idDichiarazione, "CANCELLA_DICHIARAZIONE", "Cancellazione FactoryFlow con riallineamento documenti AdHoc e saldi lotto.", ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }
    private async Task SyncAdHocDichiarazioneAsync(
        long idDichiarazione,
        DichiarazioneStoricoUpdateDto request,
        CancellationToken ct)
    {
        var config = await GetConfigAsync(ct);
        var docMast = TableName(config.PrefissoAzienda, "DOC_MAST");
        var docDett = TableName(config.PrefissoAzienda, "DOC_DETT");
        var saldiLot = TableName(config.PrefissoAzienda, "SALDILOT");
        var componentiJson = JsonSerializer.Serialize(request.Componenti);

        await using var conn = new SqlConnection(_adHocConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        try
        {
            await using var cmd = new SqlCommand($"""
                DECLARE @SerialCarico varchar(10), @SerialScarico varchar(10), @CodArticoloPF varchar(20);

                SELECT
                    @SerialCarico = SerialeCaricoAdhoc,
                    @SerialScarico = SerialeScaricoAdhoc,
                    @CodArticoloPF = CodArticoloPF
                FROM DB_FARMFLOW.dbo.FF_DICHIARAZIONI_PRODUZIONE WITH (UPDLOCK, HOLDLOCK)
                WHERE IdDichiarazione = @IdDichiarazione;

                IF @SerialCarico IS NULL OR @SerialScarico IS NULL
                    RETURN;

                ;WITH MovLotti AS
                (
                    SELECT
                        D.MVLOTMAG AS SUCODMAG,
                        D.MVKEYSAL AS SUCODART,
                        ISNULL(D.MVCODUBI, '') AS SUCODUBI,
                        D.MVCODLOT AS SUCODLOT,
                        SUM(CASE D.MVFLCASC WHEN '+' THEN ISNULL(D.MVQTAUM1, 0) WHEN '-' THEN -ISNULL(D.MVQTAUM1, 0) ELSE 0 END) AS DeltaAper,
                        SUM(CASE D.MVFLRISE WHEN '+' THEN ISNULL(D.MVQTASAL, 0) WHEN '-' THEN -ISNULL(D.MVQTASAL, 0) ELSE 0 END) AS DeltaRiser
                    FROM {docDett} D
                    WHERE D.MVSERIAL IN (@SerialCarico, @SerialScarico)
                      AND NULLIF(LTRIM(RTRIM(D.MVLOTMAG)), '') IS NOT NULL
                      AND NULLIF(LTRIM(RTRIM(D.MVCODLOT)), '') IS NOT NULL
                    GROUP BY D.MVLOTMAG, D.MVKEYSAL, ISNULL(D.MVCODUBI, ''), D.MVCODLOT
                )
                UPDATE S
                SET S.SUQTAPER = ISNULL(S.SUQTAPER, 0) - M.DeltaAper,
                    S.SUQTRPER = ISNULL(S.SUQTRPER, 0) - M.DeltaRiser,
                    S.UTCV = 1,
                    S.UTDV = GETDATE(),
                    S.CPCCCHK = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                FROM {saldiLot} S
                JOIN MovLotti M
                  ON S.SUCODMAG = M.SUCODMAG
                 AND S.SUCODART = M.SUCODART
                 AND S.SUCODUBI = M.SUCODUBI
                 AND S.SUCODLOT = M.SUCODLOT;

                UPDATE {docMast}
                SET MVDATREG = @DataProduzione,
                    MVDATDOC = @DataProduzione,
                    MVDATCIV = @DataProduzione,
                    MV__ANNO = YEAR(@DataProduzione),
                    MV__MESE = MONTH(@DataProduzione),
                    UTDV = GETDATE(),
                    cpccchk = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                WHERE MVSERIAL IN (@SerialCarico, @SerialScarico);

                UPDATE {docDett}
                SET MVQTAMOV = @QuantitaProdotta,
                    MVQTAUM1 = @QuantitaProdotta,
                    MVQTASAL = @QuantitaProdotta,
                    MVCODMAG = @MagazzinoPF,
                    MVLOTMAG = CASE WHEN NULLIF(LTRIM(RTRIM(MVFLLOTT)), '') IS NOT NULL THEN @MagazzinoPF ELSE MVLOTMAG END,
                    MVCODLOT = CASE WHEN NULLIF(LTRIM(RTRIM(MVFLLOTT)), '') IS NOT NULL THEN NULLIF(@LottoPF, '') ELSE MVCODLOT END,
                    MVDATEVA = @DataProduzione,
                    MVDATOAI = @DataProduzione,
                    cpccchk = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                WHERE MVSERIAL = @SerialCarico
                  AND LTRIM(RTRIM(MVKEYSAL)) = LTRIM(RTRIM(@CodArticoloPF));

                ;WITH C AS
                (
                    SELECT *
                    FROM OPENJSON(@ComponentiJson)
                    WITH
                    (
                        CodComponente varchar(20) '$.CodComponente',
                        QuantitaEffettiva decimal(18,6) '$.QuantitaEffettiva',
                        Lotto varchar(30) '$.Lotto',
                        Magazzino varchar(5) '$.Magazzino'
                    )
                )
                UPDATE D
                SET D.MVQTAMOV = C.QuantitaEffettiva,
                    D.MVQTAUM1 = C.QuantitaEffettiva,
                    D.MVQTASAL = C.QuantitaEffettiva,
                    D.MVCODMAG = C.Magazzino,
                    D.MVLOTMAG = CASE WHEN NULLIF(LTRIM(RTRIM(D.MVFLLOTT)), '') IS NOT NULL THEN C.Magazzino ELSE D.MVLOTMAG END,
                    D.MVCODLOT = CASE WHEN NULLIF(LTRIM(RTRIM(D.MVFLLOTT)), '') IS NOT NULL THEN NULLIF(C.Lotto, '') ELSE D.MVCODLOT END,
                    D.MVDATEVA = @DataProduzione,
                    D.cpccchk = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                FROM {docDett} D
                JOIN C ON LTRIM(RTRIM(C.CodComponente)) = LTRIM(RTRIM(D.MVCODART))
                WHERE D.MVSERIAL = @SerialScarico;

                ;WITH MovLotti AS
                (
                    SELECT
                        D.MVLOTMAG AS SUCODMAG,
                        D.MVKEYSAL AS SUCODART,
                        ISNULL(D.MVCODUBI, '') AS SUCODUBI,
                        D.MVCODLOT AS SUCODLOT,
                        SUM(CASE D.MVFLCASC WHEN '+' THEN ISNULL(D.MVQTAUM1, 0) WHEN '-' THEN -ISNULL(D.MVQTAUM1, 0) ELSE 0 END) AS DeltaAper,
                        SUM(CASE D.MVFLRISE WHEN '+' THEN ISNULL(D.MVQTASAL, 0) WHEN '-' THEN -ISNULL(D.MVQTASAL, 0) ELSE 0 END) AS DeltaRiser
                    FROM {docDett} D
                    WHERE D.MVSERIAL IN (@SerialCarico, @SerialScarico)
                      AND NULLIF(LTRIM(RTRIM(D.MVLOTMAG)), '') IS NOT NULL
                      AND NULLIF(LTRIM(RTRIM(D.MVCODLOT)), '') IS NOT NULL
                    GROUP BY D.MVLOTMAG, D.MVKEYSAL, ISNULL(D.MVCODUBI, ''), D.MVCODLOT
                )
                UPDATE S
                SET S.SUQTAPER = ISNULL(S.SUQTAPER, 0) + M.DeltaAper,
                    S.SUQTRPER = ISNULL(S.SUQTRPER, 0) + M.DeltaRiser,
                    S.UTCV = 1,
                    S.UTDV = GETDATE(),
                    S.CPCCCHK = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                FROM {saldiLot} S
                JOIN MovLotti M
                  ON S.SUCODMAG = M.SUCODMAG
                 AND S.SUCODART = M.SUCODART
                 AND S.SUCODUBI = M.SUCODUBI
                 AND S.SUCODLOT = M.SUCODLOT;
                """, conn, (SqlTransaction)tx);

            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            cmd.Parameters.Add("@DataProduzione", SqlDbType.Date).Value = request.DataProduzione.Date;
            cmd.Parameters.Add("@MagazzinoPF", SqlDbType.VarChar, 5).Value = request.MagazzinoPF.Trim();
            cmd.Parameters.Add("@LottoPF", SqlDbType.VarChar, 30).Value = DbValue(request.LottoPF, 30);
            cmd.Parameters.Add("@QuantitaProdotta", SqlDbType.Decimal).Value = request.QuantitaProdotta;
            cmd.Parameters["@QuantitaProdotta"].Precision = 18;
            cmd.Parameters["@QuantitaProdotta"].Scale = 3;
            cmd.Parameters.Add("@ComponentiJson", SqlDbType.NVarChar, -1).Value = componentiJson;
            await cmd.ExecuteNonQueryAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }

    private async Task CancellaAdHocDichiarazioneAsync(long idDichiarazione, CancellationToken ct)
    {
        var config = await GetConfigAsync(ct);
        var docMast = TableName(config.PrefissoAzienda, "DOC_MAST");
        var docDett = TableName(config.PrefissoAzienda, "DOC_DETT");
        var saldiLot = TableName(config.PrefissoAzienda, "SALDILOT");

        await using var conn = new SqlConnection(_adHocConnectionString);
        await conn.OpenAsync(ct);
        await using var tx = await conn.BeginTransactionAsync(ct);

        try
        {
            await using var cmd = new SqlCommand($"""
                DECLARE @SerialCarico varchar(10), @SerialScarico varchar(10);

                SELECT @SerialCarico = SerialeCaricoAdhoc,
                       @SerialScarico = SerialeScaricoAdhoc
                FROM DB_FARMFLOW.dbo.FF_DICHIARAZIONI_PRODUZIONE WITH (UPDLOCK, HOLDLOCK)
                WHERE IdDichiarazione = @IdDichiarazione;

                IF @SerialCarico IS NULL OR @SerialScarico IS NULL
                    RETURN;

                ;WITH MovLotti AS
                (
                    SELECT
                        D.MVLOTMAG AS SUCODMAG,
                        D.MVKEYSAL AS SUCODART,
                        ISNULL(D.MVCODUBI, '') AS SUCODUBI,
                        D.MVCODLOT AS SUCODLOT,
                        SUM(CASE D.MVFLCASC WHEN '+' THEN ISNULL(D.MVQTAUM1, 0) WHEN '-' THEN -ISNULL(D.MVQTAUM1, 0) ELSE 0 END) AS DeltaAper,
                        SUM(CASE D.MVFLRISE WHEN '+' THEN ISNULL(D.MVQTASAL, 0) WHEN '-' THEN -ISNULL(D.MVQTASAL, 0) ELSE 0 END) AS DeltaRiser
                    FROM {docDett} D
                    WHERE D.MVSERIAL IN (@SerialCarico, @SerialScarico)
                      AND NULLIF(LTRIM(RTRIM(D.MVLOTMAG)), '') IS NOT NULL
                      AND NULLIF(LTRIM(RTRIM(D.MVCODLOT)), '') IS NOT NULL
                    GROUP BY D.MVLOTMAG, D.MVKEYSAL, ISNULL(D.MVCODUBI, ''), D.MVCODLOT
                )
                UPDATE S
                SET S.SUQTAPER = ISNULL(S.SUQTAPER, 0) - M.DeltaAper,
                    S.SUQTRPER = ISNULL(S.SUQTRPER, 0) - M.DeltaRiser,
                    S.UTCV = 1,
                    S.UTDV = GETDATE(),
                    S.CPCCCHK = LOWER(LEFT(REPLACE(CONVERT(varchar(36), NEWID()), '-', ''), 10))
                FROM {saldiLot} S
                JOIN MovLotti M
                  ON S.SUCODMAG = M.SUCODMAG
                 AND S.SUCODART = M.SUCODART
                 AND S.SUCODUBI = M.SUCODUBI
                 AND S.SUCODLOT = M.SUCODLOT;

                DELETE FROM {docDett} WHERE MVSERIAL IN (@SerialCarico, @SerialScarico);
                DELETE FROM {docMast} WHERE MVSERIAL IN (@SerialCarico, @SerialScarico);
                """, conn, (SqlTransaction)tx);

            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            await cmd.ExecuteNonQueryAsync(ct);
            await tx.CommitAsync(ct);
        }
        catch
        {
            await tx.RollbackAsync(ct);
            throw;
        }
    }
    private async Task EnrichGestioneLottiComponentiAsync(
        List<DichiarazioneStoricoComponenteDto> componenti,
        CancellationToken ct)
    {
        var codici = componenti
            .Select(c => c.CodComponente.Trim())
            .Where(c => !string.IsNullOrWhiteSpace(c))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (codici.Count == 0)
            return;

        var config = await GetConfigAsync(ct);
        var artIcol = TableName(config.PrefissoAzienda, "ART_ICOL");
        var parameterNames = codici.Select((_, index) => "@Cod" + index).ToList();

        await using var conn = new SqlConnection(_adHocConnectionString);
        await using var cmd = new SqlCommand($@"
            SELECT
                LTRIM(RTRIM(ARCODART)) AS CodArticolo,
                CAST(CASE WHEN ISNULL(ARFLLOTT, '') = 'S' THEN 1 ELSE 0 END AS bit) AS GestioneLotti
            FROM {artIcol}
            WHERE LTRIM(RTRIM(ARCODART)) IN ({string.Join(", ", parameterNames)});", conn);

        for (var i = 0; i < codici.Count; i++)
            cmd.Parameters.Add(parameterNames[i], SqlDbType.VarChar, 50).Value = codici[i];

        var flags = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            flags[GetString(reader, "CodArticolo")] = GetBool(reader, "GestioneLotti");

        foreach (var componente in componenti)
            componente.GestioneLotti = flags.TryGetValue(componente.CodComponente.Trim(), out var gestioneLotti) && gestioneLotti;
    }

    private async Task<ConfigurazioneAttivaDto> GetConfigAsync(CancellationToken ct)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            SELECT TOP (1)
                IdConfig,
                LTRIM(RTRIM(CodAziAdhoc)) AS CodAziAdhoc,
                LTRIM(RTRIM(PrefissoAzienda)) AS PrefissoAzienda,
                LTRIM(RTRIM(CausaleCarico)) AS CausaleCarico,
                LTRIM(RTRIM(CausaleScarico)) AS CausaleScarico,
                LTRIM(RTRIM(MagazzinoPFDefault)) AS MagazzinoPFDefault,
                LTRIM(RTRIM(MagazzinoComponentiDefault)) AS MagazzinoComponentiDefault
            FROM dbo.FF_CONFIG
            WHERE Attiva = 1
            ORDER BY IdConfig DESC;
            """, conn);

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);

        if (!await reader.ReadAsync(ct))
            throw new InvalidOperationException("Configurazione FactoryFlow attiva mancante.");

        return new ConfigurazioneAttivaDto
        {
            IdConfig = Convert.ToInt32(reader["IdConfig"]),
            CodAziAdhoc = GetString(reader, "CodAziAdhoc"),
            PrefissoAzienda = GetString(reader, "PrefissoAzienda"),
            CausaleCarico = GetString(reader, "CausaleCarico"),
            CausaleScarico = GetString(reader, "CausaleScarico"),
            MagazzinoPFDefault = GetString(reader, "MagazzinoPFDefault"),
            MagazzinoComponentiDefault = GetString(reader, "MagazzinoComponentiDefault")
        };
    }

    private static string TableName(string prefix, string suffix)
    {
        return SafeSqlIdentifier(prefix.Trim() + suffix);
    }

    private static string SafeSqlIdentifier(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException("Identificativo SQL mancante.");

        var trimmed = value.Trim();
        if (trimmed.Any(c => !(char.IsLetterOrDigit(c) || c == '_')))
            throw new InvalidOperationException($"Identificativo SQL non valido: {value}");

        return $"[{trimmed}]";
    }

    private static DichiarazioneStoricoDto ReadDichiarazione(SqlDataReader reader)
    {
        return new DichiarazioneStoricoDto
        {
            IdDichiarazione = Convert.ToInt64(reader["IdDichiarazione"]),
            IdLinea = GetNullableInt(reader, "IdLinea"),
            CodLinea = GetNullableString(reader, "CodLinea"),
            NomeLinea = GetNullableString(reader, "NomeLinea"),
            IdMacchina = GetNullableInt(reader, "IdMacchina"),
            CodMacchina = GetNullableString(reader, "CodMacchina"),
            NomeMacchina = GetNullableString(reader, "NomeMacchina"),
            CodAziAdhoc = GetString(reader, "CodAziAdhoc"),
            DataProduzione = Convert.ToDateTime(reader["DataProduzione"]),
            OraInizioProduzione = GetNullableDate(reader, "OraInizioProduzione"),
            OraFineProduzione = GetNullableDate(reader, "OraFineProduzione"),
            CodArticoloPF = GetString(reader, "CodArticoloPF"),
            DescrizionePF = GetNullableString(reader, "DescrizionePF"),
            LottoPF = GetNullableString(reader, "LottoPF"),
            MagazzinoPF = GetString(reader, "MagazzinoPF"),
            QuantitaProdotta = GetDecimal(reader, "QuantitaProdotta"),
            ProduttivitaMinuto = GetNullableDecimal(reader, "ProduttivitaMinuto"),
            MediaProduttivitaMinuto = GetNullableDecimal(reader, "MediaProduttivitaMinuto"),
            ScostamentoProduttivitaPercentuale = GetNullableDecimal(reader, "ScostamentoProduttivitaPercentuale"),
            SerialeCaricoAdhoc = GetNullableString(reader, "SerialeCaricoAdhoc"),
            NumeroCaricoAdhoc = GetNullableInt(reader, "NumeroCaricoAdhoc"),
            SerialeScaricoAdhoc = GetNullableString(reader, "SerialeScaricoAdhoc"),
            NumeroScaricoAdhoc = GetNullableInt(reader, "NumeroScaricoAdhoc"),
            Stato = GetString(reader, "Stato"),
            DataCreazione = Convert.ToDateTime(reader["DataCreazione"]),
            DataModifica = reader["DataModifica"] == DBNull.Value ? null : Convert.ToDateTime(reader["DataModifica"])
        };
    }

    private static async Task InsertDichiarazioneOperatoriAsync(
        SqlConnection conn,
        SqlTransaction tx,
        long idDichiarazione,
        IEnumerable<DichiarazioneOperatoreDto> operatori,
        CancellationToken ct)
    {
        foreach (var operatore in operatori)
        {
            await using var cmd = new SqlCommand("""
                INSERT INTO dbo.FF_DICHIARAZIONI_OPERATORI
                    (IdDichiarazione, IdOperatore, IdRuoloOperativo,
                     CodOperatoreSnapshot, NomeOperatoreSnapshot, RuoloSnapshot,
                     OraInizio, OraFine, Note, UtenteCreazione)
                VALUES
                    (@IdDichiarazione, @IdOperatore, @IdRuoloOperativo,
                     @CodOperatoreSnapshot, @NomeOperatoreSnapshot, @RuoloSnapshot,
                     @OraInizio, @OraFine, @Note, @Utente);
                """, conn, tx);

            cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = idDichiarazione;
            cmd.Parameters.Add("@IdOperatore", SqlDbType.Int).Value = operatore.IdOperatore.HasValue ? operatore.IdOperatore.Value : DBNull.Value;
            cmd.Parameters.Add("@IdRuoloOperativo", SqlDbType.Int).Value = operatore.IdRuoloOperativo.HasValue ? operatore.IdRuoloOperativo.Value : DBNull.Value;
            cmd.Parameters.Add("@CodOperatoreSnapshot", SqlDbType.VarChar, 20).Value = DbValue(operatore.CodOperatoreSnapshot, 20);
            cmd.Parameters.Add("@NomeOperatoreSnapshot", SqlDbType.VarChar, 150).Value = DbValue(operatore.NomeOperatoreSnapshot, 150);
            cmd.Parameters.Add("@RuoloSnapshot", SqlDbType.VarChar, 100).Value = DbValue(operatore.RuoloSnapshot, 100);
            cmd.Parameters.Add("@OraInizio", SqlDbType.DateTime2).Value = operatore.OraInizio.HasValue ? operatore.OraInizio.Value : DBNull.Value;
            cmd.Parameters.Add("@OraFine", SqlDbType.DateTime2).Value = operatore.OraFine.HasValue ? operatore.OraFine.Value : DBNull.Value;
            cmd.Parameters.Add("@Note", SqlDbType.VarChar, -1).Value = string.IsNullOrWhiteSpace(operatore.Note) ? DBNull.Value : operatore.Note.Trim();
            cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
            await cmd.ExecuteNonQueryAsync(ct);
        }
    }

    private static DichiarazioneOperatoreDto ReadDichiarazioneOperatore(SqlDataReader reader)
    {
        return new DichiarazioneOperatoreDto
        {
            IdDichiarazioneOperatore = Convert.ToInt64(reader["IdDichiarazioneOperatore"]),
            IdOperatore = GetNullableInt(reader, "IdOperatore"),
            IdRuoloOperativo = GetNullableInt(reader, "IdRuoloOperativo"),
            CodOperatoreSnapshot = GetNullableString(reader, "CodOperatoreSnapshot"),
            NomeOperatoreSnapshot = GetNullableString(reader, "NomeOperatoreSnapshot"),
            RuoloSnapshot = GetNullableString(reader, "RuoloSnapshot"),
            OraInizio = GetNullableDate(reader, "OraInizio"),
            OraFine = GetNullableDate(reader, "OraFine"),
            Note = GetNullableString(reader, "Note")
        };
    }
    private static DichiarazioneStoricoComponenteDto ReadDichiarazioneComponente(SqlDataReader reader)
    {
        return new DichiarazioneStoricoComponenteDto
        {
            IdRiga = Convert.ToInt64(reader["IdRiga"]),
            CodComponente = GetString(reader, "CodComponente"),
            DescrizioneComponente = GetNullableString(reader, "DescrizioneComponente"),
            UnitaMisura = GetNullableString(reader, "UnitaMisura"),
            QuantitaDistinta = GetNullableDecimal(reader, "QuantitaDistinta"),
            QuantitaProposta = GetNullableDecimal(reader, "QuantitaProposta"),
            QuantitaEffettiva = GetDecimal(reader, "QuantitaEffettiva"),
            Lotto = GetNullableString(reader, "Lotto"),
            Magazzino = GetString(reader, "Magazzino")
        };
    }

    private static async Task InsertAuditAsync(
        SqlConnection conn,
        SqlTransaction tx,
        long idDichiarazione,
        string tipoEvento,
        string descrizione,
        CancellationToken ct)
    {
        await using var auditCmd = new SqlCommand("""
            INSERT INTO dbo.FF_AUDIT_EVENTI (Entita, IdEntita, TipoEvento, Descrizione, Utente)
            VALUES ('FF_DICHIARAZIONI_PRODUZIONE', @IdEntita, @TipoEvento, @Descrizione, @Utente);
            """, conn, tx);
        auditCmd.Parameters.Add("@IdEntita", SqlDbType.VarChar, 50).Value = idDichiarazione.ToString();
        auditCmd.Parameters.Add("@TipoEvento", SqlDbType.VarChar, 50).Value = tipoEvento;
        auditCmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, -1).Value = descrizione;
        auditCmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
        await auditCmd.ExecuteNonQueryAsync(ct);
    }
    private static ArticoloProduzioneDto ReadArticolo(SqlDataReader reader)
    {
        return new ArticoloProduzioneDto
        {
            CodArticolo = GetString(reader, "CodArticolo"),
            Descrizione = GetString(reader, "Descrizione"),
            UnitaMisura = GetString(reader, "UnitaMisura"),
            CodiceDistinta = GetString(reader, "CodiceDistinta"),
            GestioneLotti = GetBool(reader, "GestioneLotti")
        };
    }

    private static decimal? GetNullableDecimal(SqlDataReader reader, string field) =>
        reader[field] == DBNull.Value ? null : Convert.ToDecimal(reader[field]);
    private static void AddNullableDecimal(SqlCommand cmd, string name, decimal? value)
    {
        var p = cmd.Parameters.Add(name, SqlDbType.Decimal);
        p.Precision = 18;
        p.Scale = 6;
        p.Value = value.HasValue ? value.Value : DBNull.Value;
    }

    private static object DbValue(string? value, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value))
            return DBNull.Value;

        var trimmed = value.Trim();
        return trimmed.Length <= maxLength ? trimmed : trimmed[..maxLength];
    }

    private static string GetString(SqlDataReader reader, string field)
    {
        return reader[field]?.ToString()?.Trim() ?? "";
    }

    private static string? GetNullableString(SqlDataReader reader, string field)
    {
        return HasField(reader, field) && reader[field] != DBNull.Value
            ? reader[field]?.ToString()?.Trim()
            : null;
    }

    private static int? GetNullableInt(SqlDataReader reader, string field)
    {
        return HasField(reader, field) && reader[field] != DBNull.Value
            ? Convert.ToInt32(reader[field])
            : null;
    }

    private static decimal GetDecimal(SqlDataReader reader, string field)
    {
        return reader[field] == DBNull.Value ? 0 : Convert.ToDecimal(reader[field]);
    }

    private static bool GetBool(SqlDataReader reader, string field)
    {
        return reader[field] != DBNull.Value && Convert.ToBoolean(reader[field]);
    }

    private static DateTime? GetNullableDate(SqlDataReader reader, string field)
    {
        return reader[field] == DBNull.Value ? null : Convert.ToDateTime(reader[field]);
    }

    private static bool HasField(SqlDataReader reader, string field)
    {
        for (var i = 0; i < reader.FieldCount; i++)
        {
            if (string.Equals(reader.GetName(i), field, StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }
}




















