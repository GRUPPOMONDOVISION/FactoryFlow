using System.Data;
using FactoryFlow.Api.Services;
using FactoryFlow.Core.Models.Operatori;
using FactoryFlow.Core.Models.Produzione;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/chiusure-fase")]
public sealed class ChiusureFaseController : ControllerBase
{
    private readonly string _connectionString;
    private readonly ProduzioneService _produzioneService;

    public ChiusureFaseController(IConfiguration configuration, ProduzioneService produzioneService)
    {
        _connectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
        _produzioneService = produzioneService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ChiusuraFaseDto>>> List([FromQuery] long? idAttivita, [FromQuery] int? idFase, CancellationToken ct)
    {
        var result = new List<ChiusuraFaseDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = new SqlCommand("""
            SELECT C.IdChiusuraFase, C.IdAttivita, C.IdFase, C.IdDichiarazione, C.DataChiusura, C.Stato,
                   C.IdLinea, L.CodLinea, L.NomeLinea,
                   C.IdMacchina, M.CodMacchina, M.NomeMacchina,
                   C.IdTeam, T.CodTeam, T.Descrizione AS TeamDescrizione,
                   C.OraInizio, C.OraFine, C.CodArticolo, C.DescrizioneArticolo, C.Lotto, C.Magazzino,
                   C.Quantita, C.EsitoQualita, C.Note, C.GeneratoErp,
                   C.SerialCaricoAdhoc, C.NumeroCaricoAdhoc, C.SerialScaricoAdhoc, C.NumeroScaricoAdhoc
            FROM dbo.FF_CHIUSURE_FASE C
            LEFT JOIN dbo.FF_LINEE_LAVORAZIONE L ON L.IdLinea = C.IdLinea
            LEFT JOIN dbo.FF_MACCHINE M ON M.IdMacchina = C.IdMacchina
            LEFT JOIN dbo.FF_TEAM_OPERATIVI T ON T.IdTeam = C.IdTeam
            WHERE (@IdAttivita IS NULL OR C.IdAttivita = @IdAttivita)
              AND (@IdFase IS NULL OR C.IdFase = @IdFase)
            ORDER BY C.DataChiusura DESC, C.IdChiusuraFase DESC;
            """, conn);
        cmd.Parameters.Add("@IdAttivita", SqlDbType.BigInt).Value = idAttivita.HasValue ? idAttivita.Value : DBNull.Value;
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = idFase.HasValue ? idFase.Value : DBNull.Value;

        await conn.OpenAsync(ct);
        await using (var reader = await cmd.ExecuteReaderAsync(ct))
        {
            while (await reader.ReadAsync(ct))
                result.Add(ReadChiusura(reader));
        }

        foreach (var row in result)
        {
            row.Componenti = await LoadComponentiAsync(conn, row.IdChiusuraFase, ct);
            row.Operatori = await LoadOperatoriAsync(conn, row.IdChiusuraFase, ct);
        }

        return Ok(result);
    }
    [HttpPost]
    public async Task<ActionResult<ChiusuraFaseResultDto>> Save([FromBody] ChiusuraFaseRequestDto request, CancellationToken ct)
    {
        if (request.IdFase <= 0)
            return BadRequest("Fase processo obbligatoria.");

        if (request.DataChiusura == default)
            return BadRequest("Data chiusura obbligatoria.");

        var requisiti = await GetRequisitiAsync(request.IdFase, ct);
        ValidateRequest(request, requisiti);

        if (request.IdChiusuraFase.HasValue && await IsChiusuraConErpAsync(request.IdChiusuraFase.Value, ct))
            return BadRequest("La chiusura fase ha gia generato documenti ERP: serve una rettifica controllata, non una modifica diretta.");

        DichiarazioneProduzioneResultDto? erpResult = null;
        if (requisiti.GeneraErp)
        {
            var produzioneRequest = new DichiarazioneProduzioneRequestDto
            {
                IdLinea = request.IdLinea,
                IdMacchina = request.IdMacchina,
                CodAzi = request.CodAzi,
                Esercizio = request.Esercizio,
                DataProduzione = request.DataChiusura,
                OraInizioProduzione = request.OraInizio,
                OraFineProduzione = request.OraFine,
                ArticoloProdotto = request.CodArticolo ?? "",
                DescrizioneProdotto = request.DescrizioneArticolo,
                LottoProdotto = request.Lotto ?? "",
                MagazzinoProdotto = request.Magazzino ?? "",
                QuantitaProdotta = request.Quantita ?? 0,
                Componenti = request.Componenti,
                Operatori = request.Operatori
            };

            erpResult = await _produzioneService.CreaDichiarazioneAsync(produzioneRequest, ct);
        }

        var idChiusura = await SaveChiusuraAsync(request, requisiti, erpResult, ct);
        await SaveDettagliAsync(idChiusura, request, ct);

        return Ok(new ChiusuraFaseResultDto
        {
            Ok = true,
            IdChiusuraFase = idChiusura,
            GeneratoErp = requisiti.GeneraErp,
            Messaggio = requisiti.GeneraErp
                ? erpResult?.Messaggio ?? "Chiusura fase con effetto ERP registrata."
                : "Chiusura fase registrata senza effetto ERP.",
            Erp = erpResult
        });
    }

    private static void ValidateRequest(ChiusuraFaseRequestDto request, FaseRequisitiDto requisiti)
    {
        if (requisiti.RichiedeOrari && (!request.OraInizio.HasValue || !request.OraFine.HasValue))
            throw new InvalidOperationException("La fase richiede ora inizio e ora fine.");

        if (request.OraInizio.HasValue && request.OraFine.HasValue && request.OraFine <= request.OraInizio)
            throw new InvalidOperationException("Ora fine deve essere successiva a ora inizio.");

        if (requisiti.RichiedeMacchina && !request.IdMacchina.HasValue)
            throw new InvalidOperationException("La fase richiede una macchina.");

        if (requisiti.RichiedeTeam && !request.IdTeam.HasValue && request.Operatori.Count == 0)
            throw new InvalidOperationException("La fase richiede un team o operatori.");

        if (requisiti.RichiedeArticolo && string.IsNullOrWhiteSpace(request.CodArticolo))
            throw new InvalidOperationException("La fase richiede un articolo prodotto.");

        if (requisiti.RichiedeLotto && string.IsNullOrWhiteSpace(request.Lotto))
            throw new InvalidOperationException("La fase richiede un lotto.");

        if (requisiti.RichiedeComponenti && request.Componenti.Count == 0)
            throw new InvalidOperationException("La fase richiede componenti consumati.");

        if (requisiti.GeneraErp && (!request.Quantita.HasValue || request.Quantita <= 0))
            throw new InvalidOperationException("La fase con effetto ERP richiede una quantita positiva.");
    }

    private async Task<FaseRequisitiDto> GetRequisitiAsync(int idFase, CancellationToken ct)
    {
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_ProcessiFasiRequisiti_Get", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = idFase;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        if (!await reader.ReadAsync(ct))
            throw new InvalidOperationException("Requisiti fase non trovati.");

        return new FaseRequisitiDto
        {
            IdFase = Convert.ToInt32(reader["IdFase"]),
            RichiedeMacchina = Convert.ToBoolean(reader["RichiedeMacchina"]),
            RichiedeTeam = Convert.ToBoolean(reader["RichiedeTeam"]),
            RichiedeSetup = Convert.ToBoolean(reader["RichiedeSetup"]),
            RichiedeOrari = Convert.ToBoolean(reader["RichiedeOrari"]),
            RichiedeArticolo = Convert.ToBoolean(reader["RichiedeArticolo"]),
            RichiedeLotto = Convert.ToBoolean(reader["RichiedeLotto"]),
            RichiedeComponenti = Convert.ToBoolean(reader["RichiedeComponenti"]),
            RichiedeControlloQualita = Convert.ToBoolean(reader["RichiedeControlloQualita"]),
            RichiedeNote = Convert.ToBoolean(reader["RichiedeNote"]),
            GeneraErp = Convert.ToBoolean(reader["GeneraErp"]),
            GeneraCaricoPf = Convert.ToBoolean(reader["GeneraCaricoPf"]),
            GeneraScaricoComponenti = Convert.ToBoolean(reader["GeneraScaricoComponenti"])
        };
    }

    private async Task<long> SaveChiusuraAsync(ChiusuraFaseRequestDto request, FaseRequisitiDto requisiti, DichiarazioneProduzioneResultDto? erpResult, CancellationToken ct)
    {
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_ChiusureFase_Save", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = request.IdChiusuraFase.HasValue ? request.IdChiusuraFase.Value : DBNull.Value;
        cmd.Parameters.Add("@IdAttivita", SqlDbType.BigInt).Value = request.IdAttivita.HasValue ? request.IdAttivita.Value : DBNull.Value;
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = request.IdFase;
        cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = DBNull.Value;
        cmd.Parameters.Add("@DataChiusura", SqlDbType.Date).Value = request.DataChiusura.Date;
        cmd.Parameters.Add("@Stato", SqlDbType.VarChar, 20).Value = request.Stato;
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
        cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
        cmd.Parameters.Add("@IdTeam", SqlDbType.Int).Value = request.IdTeam.HasValue ? request.IdTeam.Value : DBNull.Value;
        cmd.Parameters.Add("@OraInizio", SqlDbType.DateTime2).Value = request.OraInizio.HasValue ? request.OraInizio.Value : DBNull.Value;
        cmd.Parameters.Add("@OraFine", SqlDbType.DateTime2).Value = request.OraFine.HasValue ? request.OraFine.Value : DBNull.Value;
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 30).Value = DbValue(request.CodArticolo, 30);
        cmd.Parameters.Add("@DescrizioneArticolo", SqlDbType.VarChar, 200).Value = DbValue(request.DescrizioneArticolo, 200);
        cmd.Parameters.Add("@Lotto", SqlDbType.VarChar, 50).Value = DbValue(request.Lotto, 50);
        cmd.Parameters.Add("@Magazzino", SqlDbType.VarChar, 10).Value = DbValue(request.Magazzino, 10);
        AddDecimal(cmd, "@Quantita", request.Quantita, 18, 6);
        cmd.Parameters.Add("@EsitoQualita", SqlDbType.VarChar, 30).Value = DbValue(request.EsitoQualita, 30);
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 1000).Value = DbValue(request.Note, 1000);
        cmd.Parameters.Add("@GeneratoErp", SqlDbType.Bit).Value = requisiti.GeneraErp;
        cmd.Parameters.Add("@SerialCaricoAdhoc", SqlDbType.VarChar, 20).Value = DbValue(erpResult?.SerialCarico, 20);
        cmd.Parameters.Add("@NumeroCaricoAdhoc", SqlDbType.Int).Value = erpResult?.NumeroCarico.HasValue == true ? erpResult.NumeroCarico.Value : DBNull.Value;
        cmd.Parameters.Add("@SerialScaricoAdhoc", SqlDbType.VarChar, 20).Value = DbValue(erpResult?.SerialScarico, 20);
        cmd.Parameters.Add("@NumeroScaricoAdhoc", SqlDbType.Int).Value = erpResult?.NumeroScarico.HasValue == true ? erpResult.NumeroScarico.Value : DBNull.Value;

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return Convert.ToInt64(reader["IdChiusuraFase"]);
    }

    private async Task SaveDettagliAsync(long idChiusura, ChiusuraFaseRequestDto request, CancellationToken ct)
    {
        await using var conn = new SqlConnection(_connectionString);
        await conn.OpenAsync(ct);

        if (request.IdChiusuraFase.HasValue)
        {
            await using var deleteCmd = new SqlCommand("""
                DELETE FROM dbo.FF_CHIUSURE_FASE_COMPONENTI WHERE IdChiusuraFase=@IdChiusuraFase;
                DELETE FROM dbo.FF_CHIUSURE_FASE_TEAM WHERE IdChiusuraFase=@IdChiusuraFase;
                """, conn);
            deleteCmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusura;
            await deleteCmd.ExecuteNonQueryAsync(ct);
        }

        foreach (var c in request.Componenti)
        {
            await using var cmd = new SqlCommand("""
                INSERT INTO dbo.FF_CHIUSURE_FASE_COMPONENTI
                    (IdChiusuraFase, CodComponente, DescrizioneComponente, UnitaMisura, Quantita, Lotto, Magazzino)
                VALUES
                    (@IdChiusuraFase, @CodComponente, @DescrizioneComponente, @UnitaMisura, @Quantita, @Lotto, @Magazzino);
                """, conn);
            cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusura;
            cmd.Parameters.Add("@CodComponente", SqlDbType.VarChar, 30).Value = c.Codice;
            cmd.Parameters.Add("@DescrizioneComponente", SqlDbType.VarChar, 200).Value = DbValue(c.Descrizione, 200);
            cmd.Parameters.Add("@UnitaMisura", SqlDbType.VarChar, 10).Value = DbValue(c.UnitaMisura, 10);
            AddDecimal(cmd, "@Quantita", c.Quantita, 18, 6);
            cmd.Parameters.Add("@Lotto", SqlDbType.VarChar, 50).Value = DbValue(c.Lotto, 50);
            cmd.Parameters.Add("@Magazzino", SqlDbType.VarChar, 10).Value = DbValue(c.Magazzino, 10);
            await cmd.ExecuteNonQueryAsync(ct);
        }

        foreach (var o in request.Operatori)
        {
            await using var cmd = new SqlCommand("""
                INSERT INTO dbo.FF_CHIUSURE_FASE_TEAM
                    (IdChiusuraFase, IdOperatore, IdRuoloOperativo, NomeOperatoreSnapshot, RuoloSnapshot, CostoOrarioApplicato, OraInizio, OraFine, Note)
                VALUES
                    (@IdChiusuraFase, @IdOperatore, @IdRuoloOperativo, @NomeOperatoreSnapshot, @RuoloSnapshot, @CostoOrarioApplicato, @OraInizio, @OraFine, @Note);
                """, conn);
            cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusura;
            cmd.Parameters.Add("@IdOperatore", SqlDbType.Int).Value = o.IdOperatore.HasValue ? o.IdOperatore.Value : DBNull.Value;
            cmd.Parameters.Add("@IdRuoloOperativo", SqlDbType.Int).Value = o.IdRuoloOperativo.HasValue ? o.IdRuoloOperativo.Value : DBNull.Value;
            cmd.Parameters.Add("@NomeOperatoreSnapshot", SqlDbType.VarChar, 200).Value = DbValue(o.NomeOperatoreSnapshot, 200);
            cmd.Parameters.Add("@RuoloSnapshot", SqlDbType.VarChar, 100).Value = DbValue(o.RuoloSnapshot, 100);
            AddDecimal(cmd, "@CostoOrarioApplicato", null, 18, 4);
            cmd.Parameters.Add("@OraInizio", SqlDbType.DateTime2).Value = o.OraInizio.HasValue ? o.OraInizio.Value : DBNull.Value;
            cmd.Parameters.Add("@OraFine", SqlDbType.DateTime2).Value = o.OraFine.HasValue ? o.OraFine.Value : DBNull.Value;
            cmd.Parameters.Add("@Note", SqlDbType.VarChar, 500).Value = DbValue(o.Note, 500);
            await cmd.ExecuteNonQueryAsync(ct);
        }
    }


    private async Task<bool> IsChiusuraConErpAsync(long idChiusuraFase, CancellationToken ct)
    {
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = new SqlCommand("SELECT GeneratoErp FROM dbo.FF_CHIUSURE_FASE WHERE IdChiusuraFase=@IdChiusuraFase", conn);
        cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusuraFase;
        await conn.OpenAsync(ct);
        var value = await cmd.ExecuteScalarAsync(ct);
        return value != null && value != DBNull.Value && Convert.ToBoolean(value);
    }

    private static ChiusuraFaseDto ReadChiusura(SqlDataReader reader) => new()
    {
        IdChiusuraFase = Convert.ToInt64(reader["IdChiusuraFase"]),
        IdAttivita = reader["IdAttivita"] == DBNull.Value ? null : Convert.ToInt64(reader["IdAttivita"]),
        IdFase = Convert.ToInt32(reader["IdFase"]),
        IdDichiarazione = reader["IdDichiarazione"] == DBNull.Value ? null : Convert.ToInt64(reader["IdDichiarazione"]),
        DataChiusura = Convert.ToDateTime(reader["DataChiusura"]),
        Stato = reader["Stato"].ToString() ?? "",
        IdLinea = reader["IdLinea"] == DBNull.Value ? null : Convert.ToInt32(reader["IdLinea"]),
        CodLinea = reader["CodLinea"]?.ToString(),
        NomeLinea = reader["NomeLinea"]?.ToString(),
        IdMacchina = reader["IdMacchina"] == DBNull.Value ? null : Convert.ToInt32(reader["IdMacchina"]),
        CodMacchina = reader["CodMacchina"]?.ToString(),
        NomeMacchina = reader["NomeMacchina"]?.ToString(),
        IdTeam = reader["IdTeam"] == DBNull.Value ? null : Convert.ToInt32(reader["IdTeam"]),
        CodTeam = reader["CodTeam"]?.ToString(),
        TeamDescrizione = reader["TeamDescrizione"]?.ToString(),
        OraInizio = reader["OraInizio"] == DBNull.Value ? null : Convert.ToDateTime(reader["OraInizio"]),
        OraFine = reader["OraFine"] == DBNull.Value ? null : Convert.ToDateTime(reader["OraFine"]),
        CodArticolo = reader["CodArticolo"]?.ToString(),
        DescrizioneArticolo = reader["DescrizioneArticolo"]?.ToString(),
        Lotto = reader["Lotto"]?.ToString(),
        Magazzino = reader["Magazzino"]?.ToString(),
        Quantita = reader["Quantita"] == DBNull.Value ? null : Convert.ToDecimal(reader["Quantita"]),
        EsitoQualita = reader["EsitoQualita"]?.ToString(),
        Note = reader["Note"]?.ToString(),
        GeneratoErp = Convert.ToBoolean(reader["GeneratoErp"]),
        SerialCaricoAdhoc = reader["SerialCaricoAdhoc"]?.ToString(),
        NumeroCaricoAdhoc = reader["NumeroCaricoAdhoc"] == DBNull.Value ? null : Convert.ToInt32(reader["NumeroCaricoAdhoc"]),
        SerialScaricoAdhoc = reader["SerialScaricoAdhoc"]?.ToString(),
        NumeroScaricoAdhoc = reader["NumeroScaricoAdhoc"] == DBNull.Value ? null : Convert.ToInt32(reader["NumeroScaricoAdhoc"])
    };

    private static async Task<List<ChiusuraFaseComponenteDto>> LoadComponentiAsync(SqlConnection conn, long idChiusuraFase, CancellationToken ct)
    {
        var rows = new List<ChiusuraFaseComponenteDto>();
        await using var cmd = new SqlCommand("""
            SELECT IdRiga, CodComponente, DescrizioneComponente, UnitaMisura, Quantita, Lotto, Magazzino, DisponibilitaLotto, DataScadenza
            FROM dbo.FF_CHIUSURE_FASE_COMPONENTI
            WHERE IdChiusuraFase=@IdChiusuraFase
            ORDER BY IdRiga;
            """, conn);
        cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusuraFase;
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            rows.Add(new ChiusuraFaseComponenteDto
            {
                IdRiga = Convert.ToInt64(reader["IdRiga"]),
                CodComponente = reader["CodComponente"].ToString() ?? "",
                DescrizioneComponente = reader["DescrizioneComponente"]?.ToString(),
                UnitaMisura = reader["UnitaMisura"]?.ToString(),
                Quantita = Convert.ToDecimal(reader["Quantita"]),
                Lotto = reader["Lotto"]?.ToString(),
                Magazzino = reader["Magazzino"]?.ToString(),
                DisponibilitaLotto = reader["DisponibilitaLotto"] == DBNull.Value ? null : Convert.ToDecimal(reader["DisponibilitaLotto"]),
                DataScadenza = reader["DataScadenza"] == DBNull.Value ? null : Convert.ToDateTime(reader["DataScadenza"])
            });
        }
        return rows;
    }

    private static async Task<List<ChiusuraFaseOperatoreDto>> LoadOperatoriAsync(SqlConnection conn, long idChiusuraFase, CancellationToken ct)
    {
        var rows = new List<ChiusuraFaseOperatoreDto>();
        await using var cmd = new SqlCommand("""
            SELECT IdRiga, IdOperatore, IdRuoloOperativo, NomeOperatoreSnapshot, RuoloSnapshot, CostoOrarioApplicato, OraInizio, OraFine, Note
            FROM dbo.FF_CHIUSURE_FASE_TEAM
            WHERE IdChiusuraFase=@IdChiusuraFase
            ORDER BY IdRiga;
            """, conn);
        cmd.Parameters.Add("@IdChiusuraFase", SqlDbType.BigInt).Value = idChiusuraFase;
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            rows.Add(new ChiusuraFaseOperatoreDto
            {
                IdRiga = Convert.ToInt64(reader["IdRiga"]),
                IdOperatore = reader["IdOperatore"] == DBNull.Value ? null : Convert.ToInt32(reader["IdOperatore"]),
                IdRuoloOperativo = reader["IdRuoloOperativo"] == DBNull.Value ? null : Convert.ToInt32(reader["IdRuoloOperativo"]),
                NomeOperatoreSnapshot = reader["NomeOperatoreSnapshot"]?.ToString(),
                RuoloSnapshot = reader["RuoloSnapshot"]?.ToString(),
                CostoOrarioApplicato = reader["CostoOrarioApplicato"] == DBNull.Value ? null : Convert.ToDecimal(reader["CostoOrarioApplicato"]),
                OraInizio = reader["OraInizio"] == DBNull.Value ? null : Convert.ToDateTime(reader["OraInizio"]),
                OraFine = reader["OraFine"] == DBNull.Value ? null : Convert.ToDateTime(reader["OraFine"]),
                Note = reader["Note"]?.ToString()
            });
        }
        return rows;
    }
    private static void AddDecimal(SqlCommand cmd, string name, decimal? value, byte precision, byte scale)
    {
        cmd.Parameters.Add(name, SqlDbType.Decimal).Value = value.HasValue ? value.Value : DBNull.Value;
        cmd.Parameters[name].Precision = precision;
        cmd.Parameters[name].Scale = scale;
    }

    private static object DbValue(string? value, int max)
    {
        if (string.IsNullOrWhiteSpace(value)) return DBNull.Value;
        var trimmed = value.Trim();
        return trimmed.Length > max ? trimmed[..max] : trimmed;
    }
}

public sealed class ChiusuraFaseRequestDto
{
    public long? IdChiusuraFase { get; set; }
    public long? IdAttivita { get; set; }
    public int IdFase { get; set; }
    public string CodAzi { get; set; } = "";
    public int Esercizio { get; set; }
    public DateTime DataChiusura { get; set; }
    public string Stato { get; set; } = "CONSUNTIVATA";
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public int? IdTeam { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? CodArticolo { get; set; }
    public string? DescrizioneArticolo { get; set; }
    public string? Lotto { get; set; }
    public string? Magazzino { get; set; }
    public decimal? Quantita { get; set; }
    public string? EsitoQualita { get; set; }
    public string? Note { get; set; }
    public List<DichiarazioneProduzioneComponenteDto> Componenti { get; set; } = new();
    public List<DichiarazioneOperatoreDto> Operatori { get; set; } = new();
}

public sealed class ChiusuraFaseResultDto
{
    public bool Ok { get; set; }
    public long IdChiusuraFase { get; set; }
    public bool GeneratoErp { get; set; }
    public string Messaggio { get; set; } = "";
    public DichiarazioneProduzioneResultDto? Erp { get; set; }
}

public sealed class FaseRequisitiDto
{
    public int IdFase { get; set; }
    public bool RichiedeMacchina { get; set; }
    public bool RichiedeTeam { get; set; }
    public bool RichiedeSetup { get; set; }
    public bool RichiedeOrari { get; set; }
    public bool RichiedeArticolo { get; set; }
    public bool RichiedeLotto { get; set; }
    public bool RichiedeComponenti { get; set; }
    public bool RichiedeControlloQualita { get; set; }
    public bool RichiedeNote { get; set; }
    public bool GeneraErp { get; set; }
    public bool GeneraCaricoPf { get; set; }
    public bool GeneraScaricoComponenti { get; set; }
}


public sealed class ChiusuraFaseDto
{
    public long IdChiusuraFase { get; set; }
    public long? IdAttivita { get; set; }
    public int IdFase { get; set; }
    public long? IdDichiarazione { get; set; }
    public DateTime DataChiusura { get; set; }
    public string Stato { get; set; } = "";
    public int? IdLinea { get; set; }
    public string? CodLinea { get; set; }
    public string? NomeLinea { get; set; }
    public int? IdMacchina { get; set; }
    public string? CodMacchina { get; set; }
    public string? NomeMacchina { get; set; }
    public int? IdTeam { get; set; }
    public string? CodTeam { get; set; }
    public string? TeamDescrizione { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? CodArticolo { get; set; }
    public string? DescrizioneArticolo { get; set; }
    public string? Lotto { get; set; }
    public string? Magazzino { get; set; }
    public decimal? Quantita { get; set; }
    public string? EsitoQualita { get; set; }
    public string? Note { get; set; }
    public bool GeneratoErp { get; set; }
    public string? SerialCaricoAdhoc { get; set; }
    public int? NumeroCaricoAdhoc { get; set; }
    public string? SerialScaricoAdhoc { get; set; }
    public int? NumeroScaricoAdhoc { get; set; }
    public List<ChiusuraFaseComponenteDto> Componenti { get; set; } = new();
    public List<ChiusuraFaseOperatoreDto> Operatori { get; set; } = new();
}

public sealed class ChiusuraFaseComponenteDto
{
    public long IdRiga { get; set; }
    public string CodComponente { get; set; } = "";
    public string? DescrizioneComponente { get; set; }
    public string? UnitaMisura { get; set; }
    public decimal Quantita { get; set; }
    public string? Lotto { get; set; }
    public string? Magazzino { get; set; }
    public decimal? DisponibilitaLotto { get; set; }
    public DateTime? DataScadenza { get; set; }
}

public sealed class ChiusuraFaseOperatoreDto
{
    public long IdRiga { get; set; }
    public int? IdOperatore { get; set; }
    public int? IdRuoloOperativo { get; set; }
    public string? NomeOperatoreSnapshot { get; set; }
    public string? RuoloSnapshot { get; set; }
    public decimal? CostoOrarioApplicato { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? Note { get; set; }
}

