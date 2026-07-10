using System.Data;
using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Configurazione;
using FactoryFlow.Core.Models.Linee;
using FactoryFlow.Core.Models.Produzione;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace FactoryFlow.Infrastructure.Repositories;

public sealed class LineeRepository : ILineeRepository
{
    private readonly string _adHocConnectionString;
    private readonly string _farmFlowConnectionString;

    public LineeRepository(IConfiguration configuration)
    {
        _adHocConnectionString = configuration.GetConnectionString("AdhocConnection")
            ?? configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string AdhocConnection mancante.");
        _farmFlowConnectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    public async Task<List<LineaDto>> GetLineeAsync(CancellationToken ct = default)
    {
        var result = new List<LineaDto>();

        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            SELECT IdLinea, CodLinea, NomeLinea, DescrizioneFunzionale, Attiva
            FROM dbo.FF_LINEE_LAVORAZIONE
            ORDER BY Attiva DESC, CodLinea;
            """, conn);

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            result.Add(ReadLinea(reader));

        return result;
    }

    public async Task<LineaDto> CreateLineaAsync(LineaRequestDto request, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            INSERT INTO dbo.FF_LINEE_LAVORAZIONE
                (CodLinea, NomeLinea, DescrizioneFunzionale, Attiva, UtenteCreazione)
            OUTPUT INSERTED.IdLinea, INSERTED.CodLinea, INSERTED.NomeLinea, INSERTED.DescrizioneFunzionale, INSERTED.Attiva
            VALUES
                (@CodLinea, @NomeLinea, @DescrizioneFunzionale, @Attiva, @Utente);
            """, conn);

        AddLineaParameters(cmd, request);
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return ReadLinea(reader);
    }

    public async Task<LineaDto?> UpdateLineaAsync(int id, LineaRequestDto request, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            UPDATE dbo.FF_LINEE_LAVORAZIONE
            SET CodLinea = @CodLinea,
                NomeLinea = @NomeLinea,
                DescrizioneFunzionale = @DescrizioneFunzionale,
                Attiva = @Attiva,
                DataModifica = GETDATE(),
                UtenteModifica = @Utente
            OUTPUT INSERTED.IdLinea, INSERTED.CodLinea, INSERTED.NomeLinea, INSERTED.DescrizioneFunzionale, INSERTED.Attiva
            WHERE IdLinea = @IdLinea;
            """, conn);

        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = id;
        AddLineaParameters(cmd, request);

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        return await reader.ReadAsync(ct) ? ReadLinea(reader) : null;
    }

    public async Task<List<ArticoloProduzioneDto>> GetArticoliLineaAsync(int idLinea, CancellationToken ct = default)
    {
        var config = await GetConfigAsync(ct);
        var artIcol = SafeSqlIdentifier(config.PrefissoAzienda + "ART_ICOL");
        var result = new List<ArticoloProduzioneDto>();
        var codici = new List<string>();

        await using (var conn = new SqlConnection(_farmFlowConnectionString))
        await using (var cmd = new SqlCommand("""
            SELECT CodArticolo
            FROM dbo.FF_LINEE_ARTICOLI
            WHERE IdLinea = @IdLinea AND Attivo = 1
            ORDER BY CodArticolo;
            """, conn))
        {
            cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = idLinea;
            await conn.OpenAsync(ct);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                codici.Add(GetString(reader, "CodArticolo"));
        }

        if (codici.Count == 0)
            return result;

        await using var adhocConn = new SqlConnection(_adHocConnectionString);
        await adhocConn.OpenAsync(ct);

        foreach (var codice in codici)
        {
            await using var cmd = new SqlCommand($"""
                SELECT TOP (1)
                    LTRIM(RTRIM(ARCODART)) AS CodArticolo,
                    LTRIM(RTRIM(ARDESART)) AS Descrizione,
                    LTRIM(RTRIM(ISNULL(ARUNMIS1, ''))) AS UnitaMisura,
                    LTRIM(RTRIM(ARCODDIS)) AS CodiceDistinta,
                    CAST(CASE WHEN ISNULL(ARFLLOTT, '') = 'S' THEN 1 ELSE 0 END AS bit) AS GestioneLotti
                FROM {artIcol}
                WHERE LTRIM(RTRIM(ARCODART)) = LTRIM(RTRIM(@CodArticolo))
                  AND ISNULL(LTRIM(RTRIM(ARCODDIS)), '') <> '';
                """, adhocConn);
            cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = codice;

            await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
            if (!await reader.ReadAsync(ct))
                continue;

            result.Add(new ArticoloProduzioneDto
            {
                CodArticolo = GetString(reader, "CodArticolo"),
                Descrizione = GetString(reader, "Descrizione"),
                UnitaMisura = GetString(reader, "UnitaMisura"),
                CodiceDistinta = GetString(reader, "CodiceDistinta"),
                GestioneLotti = GetBool(reader, "GestioneLotti")
            });
        }

        return result;
    }

    public async Task AddArticoloLineaAsync(int idLinea, LineaArticoloRequestDto request, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            MERGE dbo.FF_LINEE_ARTICOLI AS target
            USING (SELECT @IdLinea AS IdLinea, @CodArticolo AS CodArticolo) AS source
            ON target.IdLinea = source.IdLinea AND target.CodArticolo = source.CodArticolo
            WHEN MATCHED THEN
                UPDATE SET QuantitaMinuto = @QuantitaMinuto,
                           Attivo = @Attivo,
                           DataModifica = GETDATE(),
                           UtenteModifica = @Utente
            WHEN NOT MATCHED THEN
                INSERT (IdLinea, CodArticolo, QuantitaMinuto, Attivo, UtenteCreazione)
                VALUES (@IdLinea, @CodArticolo, @QuantitaMinuto, @Attivo, @Utente);
            """, conn);

        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = idLinea;
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = request.CodArticolo.Trim();
        var qta = cmd.Parameters.Add("@QuantitaMinuto", SqlDbType.Decimal);
        qta.Precision = 18;
        qta.Scale = 6;
        qta.Value = request.QuantitaMinuto.HasValue ? request.QuantitaMinuto.Value : DBNull.Value;
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";

        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
    }

    public async Task RemoveArticoloLineaAsync(int idLinea, string codArticolo, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("""
            UPDATE dbo.FF_LINEE_ARTICOLI
            SET Attivo = 0,
                DataModifica = GETDATE(),
                UtenteModifica = @Utente
            WHERE IdLinea = @IdLinea
              AND LTRIM(RTRIM(CodArticolo)) = LTRIM(RTRIM(@CodArticolo));
            """, conn);

        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = idLinea;
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = codArticolo.Trim();
        cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";

        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
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

    private static void AddLineaParameters(SqlCommand cmd, LineaRequestDto request)
    {
        cmd.Parameters.Add("@CodLinea", SqlDbType.VarChar, 20).Value = request.CodLinea.Trim();
        cmd.Parameters.Add("@NomeLinea", SqlDbType.VarChar, 100).Value = request.NomeLinea.Trim();
        cmd.Parameters.Add("@DescrizioneFunzionale", SqlDbType.VarChar, -1).Value =
            string.IsNullOrWhiteSpace(request.DescrizioneFunzionale) ? DBNull.Value : request.DescrizioneFunzionale.Trim();
        cmd.Parameters.Add("@Attiva", SqlDbType.Bit).Value = request.Attiva;
        cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
    }

    private static LineaDto ReadLinea(SqlDataReader reader)
    {
        return new LineaDto
        {
            IdLinea = Convert.ToInt32(reader["IdLinea"]),
            CodLinea = GetString(reader, "CodLinea"),
            NomeLinea = GetString(reader, "NomeLinea"),
            DescrizioneFunzionale = GetNullableString(reader, "DescrizioneFunzionale"),
            Attiva = GetBool(reader, "Attiva")
        };
    }

    private static string SafeSqlIdentifier(string value)
    {
        var trimmed = value.Trim();
        if (string.IsNullOrWhiteSpace(trimmed) || trimmed.Any(c => !(char.IsLetterOrDigit(c) || c == '_')))
            throw new InvalidOperationException($"Identificativo SQL non valido: {value}");

        return $"[{trimmed}]";
    }

    private static string GetString(SqlDataReader reader, string field) => reader[field]?.ToString()?.Trim() ?? "";
    private static string? GetNullableString(SqlDataReader reader, string field) =>
        reader[field] == DBNull.Value ? null : reader[field]?.ToString()?.Trim();
    private static bool GetBool(SqlDataReader reader, string field) =>
        reader[field] != DBNull.Value && Convert.ToBoolean(reader[field]);
}


