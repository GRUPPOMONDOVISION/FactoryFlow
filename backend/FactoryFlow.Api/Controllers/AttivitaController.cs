using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/attivita")]
public sealed class AttivitaController : ControllerBase
{
    private readonly string _connectionString;

    public AttivitaController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    [HttpGet]
    public async Task<ActionResult<List<AttivitaProduttivaDto>>> GetAttivita([FromQuery] DateTime? dal, [FromQuery] DateTime? al, CancellationToken ct)
    {
        var result = new List<AttivitaProduttivaDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_AttivitaProduttive_List");
        cmd.Parameters.Add("@Dal", SqlDbType.Date).Value = dal.HasValue ? dal.Value.Date : DBNull.Value;
        cmd.Parameters.Add("@Al", SqlDbType.Date).Value = al.HasValue ? al.Value.Date : DBNull.Value;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadAttivita(reader));
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<AttivitaProduttivaDto>> SaveAttivita([FromBody] AttivitaProduttivaRequest request, CancellationToken ct)
    {
        if (request.IdVersione <= 0 || request.IdFase <= 0 || request.DataProduzione == default)
            return BadRequest("Versione processo, fase e data produzione sono obbligatori.");

        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_AttivitaProduttive_Save");
        cmd.Parameters.Add("@IdAttivita", SqlDbType.BigInt).Value = request.IdAttivita.HasValue ? request.IdAttivita.Value : DBNull.Value;
        cmd.Parameters.Add("@IdVersione", SqlDbType.Int).Value = request.IdVersione;
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = request.IdFase.HasValue ? request.IdFase.Value : DBNull.Value;
        cmd.Parameters.Add("@IdDichiarazione", SqlDbType.BigInt).Value = request.IdDichiarazione.HasValue ? request.IdDichiarazione.Value : DBNull.Value;
        cmd.Parameters.Add("@DataProduzione", SqlDbType.Date).Value = request.DataProduzione.Date;
        cmd.Parameters.Add("@Stato", SqlDbType.VarChar, 20).Value = string.IsNullOrWhiteSpace(request.Stato) ? "PREVISTA" : request.Stato.Trim();
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 30).Value = string.IsNullOrWhiteSpace(request.CodArticolo) ? DBNull.Value : request.CodArticolo.Trim();
        AddDecimal(cmd, "@QuantitaPrevista", request.QuantitaPrevista, 18, 6);
        AddDecimal(cmd, "@QuantitaConsuntivata", request.QuantitaConsuntivata, 18, 6);
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
        cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
        cmd.Parameters.Add("@IdTeam", SqlDbType.Int).Value = request.IdTeam.HasValue ? request.IdTeam.Value : DBNull.Value;
        cmd.Parameters.Add("@OraInizio", SqlDbType.DateTime2).Value = request.OraInizio.HasValue ? request.OraInizio.Value : DBNull.Value;
        cmd.Parameters.Add("@OraFine", SqlDbType.DateTime2).Value = request.OraFine.HasValue ? request.OraFine.Value : DBNull.Value;
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 500).Value = DbValue(request.Note, 500);
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return Ok(ReadAttivitaBase(reader));
    }

    private static SqlCommand Stored(SqlConnection conn, string name) => new(name, conn) { CommandType = CommandType.StoredProcedure };

    private static AttivitaProduttivaDto ReadAttivita(SqlDataReader reader) => new()
    {
        IdAttivita = Convert.ToInt64(reader["IdAttivita"]),
        IdVersione = Convert.ToInt32(reader["IdVersione"]),
        IdProcesso = Convert.ToInt32(reader["IdProcesso"]),
        CodProcesso = Str(reader, "CodProcesso"),
        ProcessoDescrizione = Str(reader, "ProcessoDescrizione"),
        IdFase = NullableInt(reader, "IdFase"),
        CodFase = NullableString(reader, "CodFase"),
        FaseDescrizione = NullableString(reader, "FaseDescrizione"),
        IdDichiarazione = NullableLong(reader, "IdDichiarazione"),
        DataProduzione = Convert.ToDateTime(reader["DataProduzione"]),
        Stato = Str(reader, "Stato"),
        CodArticolo = Str(reader, "CodArticolo"),
        QuantitaPrevista = NullableDecimal(reader, "QuantitaPrevista"),
        QuantitaConsuntivata = NullableDecimal(reader, "QuantitaConsuntivata"),
        IdLinea = NullableInt(reader, "IdLinea"),
        CodLinea = NullableString(reader, "CodLinea"),
        NomeLinea = NullableString(reader, "NomeLinea"),
        IdMacchina = NullableInt(reader, "IdMacchina"),
        CodMacchina = NullableString(reader, "CodMacchina"),
        NomeMacchina = NullableString(reader, "NomeMacchina"),
        IdTeam = NullableInt(reader, "IdTeam"),
        CodTeam = NullableString(reader, "CodTeam"),
        OraInizio = NullableDate(reader, "OraInizio"),
        OraFine = NullableDate(reader, "OraFine"),
        Note = NullableString(reader, "Note")
    };

    private static AttivitaProduttivaDto ReadAttivitaBase(SqlDataReader reader) => new()
    {
        IdAttivita = Convert.ToInt64(reader["IdAttivita"]),
        IdVersione = Convert.ToInt32(reader["IdVersione"]),
        IdFase = NullableInt(reader, "IdFase"),
        IdDichiarazione = NullableLong(reader, "IdDichiarazione"),
        DataProduzione = Convert.ToDateTime(reader["DataProduzione"]),
        Stato = Str(reader, "Stato"),
        CodArticolo = Str(reader, "CodArticolo"),
        QuantitaPrevista = NullableDecimal(reader, "QuantitaPrevista"),
        QuantitaConsuntivata = NullableDecimal(reader, "QuantitaConsuntivata"),
        IdLinea = NullableInt(reader, "IdLinea"),
        IdMacchina = NullableInt(reader, "IdMacchina"),
        IdTeam = NullableInt(reader, "IdTeam"),
        OraInizio = NullableDate(reader, "OraInizio"),
        OraFine = NullableDate(reader, "OraFine"),
        Note = NullableString(reader, "Note")
    };

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

    private static string Str(SqlDataReader reader, string field) => reader[field]?.ToString()?.Trim() ?? "";
    private static string? NullableString(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Str(reader, field);
    private static int? NullableInt(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToInt32(reader[field]);
    private static long? NullableLong(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToInt64(reader[field]);
    private static decimal? NullableDecimal(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToDecimal(reader[field]);
    private static DateTime? NullableDate(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToDateTime(reader[field]);
}

public sealed class AttivitaProduttivaDto
{
    public long IdAttivita { get; set; }
    public int IdVersione { get; set; }
    public int? IdProcesso { get; set; }
    public string? CodProcesso { get; set; }
    public string? ProcessoDescrizione { get; set; }
    public int? IdFase { get; set; }
    public string? CodFase { get; set; }
    public string? FaseDescrizione { get; set; }
    public long? IdDichiarazione { get; set; }
    public DateTime DataProduzione { get; set; }
    public string Stato { get; set; } = "";
    public string? CodArticolo { get; set; }
    public decimal? QuantitaPrevista { get; set; }
    public decimal? QuantitaConsuntivata { get; set; }
    public int? IdLinea { get; set; }
    public string? CodLinea { get; set; }
    public string? NomeLinea { get; set; }
    public int? IdMacchina { get; set; }
    public string? CodMacchina { get; set; }
    public string? NomeMacchina { get; set; }
    public int? IdTeam { get; set; }
    public string? CodTeam { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? Note { get; set; }
}

public sealed class AttivitaProduttivaRequest
{
    public long? IdAttivita { get; set; }
    public int IdVersione { get; set; }
    public int? IdFase { get; set; }
    public long? IdDichiarazione { get; set; }
    public DateTime DataProduzione { get; set; }
    public string Stato { get; set; } = "PREVISTA";
    public string? CodArticolo { get; set; }
    public decimal? QuantitaPrevista { get; set; }
    public decimal? QuantitaConsuntivata { get; set; }
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public int? IdTeam { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? Note { get; set; }
}






