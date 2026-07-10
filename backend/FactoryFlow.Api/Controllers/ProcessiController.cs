using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/processi")]
public sealed class ProcessiController : ControllerBase
{
    private readonly string _connectionString;

    public ProcessiController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    [HttpGet]
    public async Task<ActionResult<List<ProcessoDto>>> GetProcessi(CancellationToken ct)
    {
        var result = new List<ProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_Processi_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadProcesso(reader));
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ProcessoDto>> SaveProcesso([FromBody] ProcessoRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CodProcesso) || string.IsNullOrWhiteSpace(request.Descrizione))
            return BadRequest("Codice processo e descrizione obbligatori.");

        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_Processi_Save");
        cmd.Parameters.Add("@IdProcesso", SqlDbType.Int).Value = request.IdProcesso.HasValue ? request.IdProcesso.Value : DBNull.Value;
        cmd.Parameters.Add("@CodProcesso", SqlDbType.VarChar, 40).Value = request.CodProcesso.Trim();
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 30).Value = DbValue(request.CodArticolo, 30);
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 200).Value = request.Descrizione.Trim();
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 500).Value = DbValue(request.Note, 500);

        cmd.Parameters.Add("@Stato", SqlDbType.VarChar, 20).Value = string.IsNullOrWhiteSpace(request.Stato) ? "BOZZA" : request.Stato.Trim();
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return Ok(ReadProcessoBase(reader));
    }

    [HttpGet("{idProcesso:int}/versioni")]
    public async Task<ActionResult<List<VersioneProcessoDto>>> GetVersioni(int idProcesso, CancellationToken ct)
    {
        var result = new List<VersioneProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_ProcessiVersioni_List");
        cmd.Parameters.Add("@IdProcesso", SqlDbType.Int).Value = idProcesso;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadVersione(reader));
        return Ok(result);
    }

    [HttpPost("{idProcesso:int}/versioni")]
    public async Task<ActionResult<List<VersioneProcessoDto>>> SaveVersione(int idProcesso, [FromBody] VersioneProcessoRequest request, CancellationToken ct)
    {
        if (request.ValidoDal == default) return BadRequest("Data validita versione obbligatoria.");

        var result = new List<VersioneProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_ProcessiVersioni_Save");
        cmd.Parameters.Add("@IdVersione", SqlDbType.Int).Value = request.IdVersione.HasValue ? request.IdVersione.Value : DBNull.Value;
        cmd.Parameters.Add("@IdProcesso", SqlDbType.Int).Value = idProcesso;
        cmd.Parameters.Add("@NumeroVersione", SqlDbType.Int).Value = request.NumeroVersione.HasValue ? request.NumeroVersione.Value : DBNull.Value;
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 200).Value = DbValue(request.Descrizione, 200);
        cmd.Parameters.Add("@Motivazione", SqlDbType.VarChar, 500).Value = DbValue(request.Motivazione, 500);
        cmd.Parameters.Add("@ValidoDal", SqlDbType.Date).Value = request.ValidoDal.Date;
        cmd.Parameters.Add("@ValidoAl", SqlDbType.Date).Value = request.ValidoAl.HasValue ? request.ValidoAl.Value.Date : DBNull.Value;
        cmd.Parameters.Add("@Stato", SqlDbType.VarChar, 20).Value = string.IsNullOrWhiteSpace(request.Stato) ? "BOZZA" : request.Stato.Trim();
        AddDecimal(cmd, "@TempoAttesoMinuti", request.TempoAttesoMinuti, 18, 3);
        AddDecimal(cmd, "@SetupAttesoMinuti", request.SetupAttesoMinuti, 18, 3);
        AddDecimal(cmd, "@ProduttivitaAttesa", request.ProduttivitaAttesa, 18, 6);
        AddDecimal(cmd, "@CostoAtteso", request.CostoAtteso, 18, 4);
        AddDecimal(cmd, "@EnergiaAttesa", request.EnergiaAttesa, 18, 6);
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadVersione(reader));
        return Ok(result);
    }

    [HttpGet("versioni/{idVersione:int}/fasi")]
    public async Task<ActionResult<List<FaseProcessoDto>>> GetFasi(int idVersione, CancellationToken ct)
    {
        var result = new List<FaseProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_ProcessiFasi_List");
        cmd.Parameters.Add("@IdVersione", SqlDbType.Int).Value = idVersione;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadFase(reader));
        return Ok(result);
    }

    [HttpPost("versioni/{idVersione:int}/fasi")]
    public async Task<ActionResult<List<FaseProcessoDto>>> SaveFase(int idVersione, [FromBody] FaseProcessoRequest request, CancellationToken ct)
    {
        if (request.Sequenza <= 0 || string.IsNullOrWhiteSpace(request.CodFase) || string.IsNullOrWhiteSpace(request.Descrizione))
            return BadRequest("Sequenza, codice fase e descrizione obbligatori.");

        var result = new List<FaseProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_ProcessiFasi_Save");
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = request.IdFase.HasValue ? request.IdFase.Value : DBNull.Value;
        cmd.Parameters.Add("@IdVersione", SqlDbType.Int).Value = idVersione;
        cmd.Parameters.Add("@Sequenza", SqlDbType.Int).Value = request.Sequenza;
        cmd.Parameters.Add("@CodFase", SqlDbType.VarChar, 40).Value = request.CodFase.Trim();
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 200).Value = request.Descrizione.Trim();
        cmd.Parameters.Add("@IdLineaDefault", SqlDbType.Int).Value = request.IdLineaDefault.HasValue ? request.IdLineaDefault.Value : DBNull.Value;
        cmd.Parameters.Add("@IdMacchinaDefault", SqlDbType.Int).Value = request.IdMacchinaDefault.HasValue ? request.IdMacchinaDefault.Value : DBNull.Value;
        AddDecimal(cmd, "@TempoStandardMinuti", request.TempoStandardMinuti, 18, 3);
        AddDecimal(cmd, "@SetupStandardMinuti", request.SetupStandardMinuti, 18, 3);
        AddDecimal(cmd, "@ProduttivitaAttesa", request.ProduttivitaAttesa, 18, 6);
        AddDecimal(cmd, "@CostoStandard", request.CostoStandard, 18, 4);
        AddDecimal(cmd, "@EnergiaAttesa", request.EnergiaAttesa, 18, 6);
        AddDecimal(cmd, "@QualitaAttesa", request.QualitaAttesa, 9, 4);
        AddDecimal(cmd, "@ScartoAtteso", request.ScartoAtteso, 9, 4);
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 500).Value = DbValue(request.Note, 500);
        cmd.Parameters.Add("@RichiedeMacchina", SqlDbType.Bit).Value = request.RichiedeMacchina;
        cmd.Parameters.Add("@RichiedeTeam", SqlDbType.Bit).Value = request.RichiedeTeam;
        cmd.Parameters.Add("@RichiedeSetup", SqlDbType.Bit).Value = request.RichiedeSetup;
        cmd.Parameters.Add("@RichiedeOrari", SqlDbType.Bit).Value = request.RichiedeOrari;
        cmd.Parameters.Add("@RichiedeArticolo", SqlDbType.Bit).Value = request.RichiedeArticolo;
        cmd.Parameters.Add("@RichiedeLotto", SqlDbType.Bit).Value = request.RichiedeLotto;
        cmd.Parameters.Add("@RichiedeComponenti", SqlDbType.Bit).Value = request.RichiedeComponenti;
        cmd.Parameters.Add("@RichiedeControlloQualita", SqlDbType.Bit).Value = request.RichiedeControlloQualita;
        cmd.Parameters.Add("@RichiedeNote", SqlDbType.Bit).Value = request.RichiedeNote;
        cmd.Parameters.Add("@GeneraErp", SqlDbType.Bit).Value = request.GeneraErp;
        cmd.Parameters.Add("@GeneraCaricoPf", SqlDbType.Bit).Value = request.GeneraCaricoPf;
        cmd.Parameters.Add("@GeneraScaricoComponenti", SqlDbType.Bit).Value = request.GeneraScaricoComponenti;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadFase(reader));
        return Ok(result);
    }

    [HttpDelete("versioni/{idVersione:int}/fasi/{idFase:int}")]
    public async Task<ActionResult<List<FaseProcessoDto>>> DeleteFase(int idVersione, int idFase, CancellationToken ct)
    {
        var result = new List<FaseProcessoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_ProcessiFasi_Delete");
        cmd.Parameters.Add("@IdVersione", SqlDbType.Int).Value = idVersione;
        cmd.Parameters.Add("@IdFase", SqlDbType.Int).Value = idFase;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadFase(reader));
        return Ok(result);
    }

    private static SqlCommand Stored(SqlConnection conn, string name) => new(name, conn) { CommandType = CommandType.StoredProcedure };

    private static ProcessoDto ReadProcesso(SqlDataReader reader) => new()
    {
        IdProcesso = Convert.ToInt32(reader["IdProcesso"]),
        CodProcesso = Str(reader, "CodProcesso"),
        CodArticolo = NullableString(reader, "CodArticolo"),
        Descrizione = Str(reader, "Descrizione"),
        Note = NullableString(reader, "Note"),
        Stato = Str(reader, "Stato"),
        IdVersioneCorrente = NullableInt(reader, "IdVersioneCorrente"),
        NumeroVersioneCorrente = NullableInt(reader, "NumeroVersioneCorrente"),
        ValidoDal = NullableDate(reader, "ValidoDal"),
        ValidoAl = NullableDate(reader, "ValidoAl")
    };

    private static ProcessoDto ReadProcessoBase(SqlDataReader reader) => new()
    {
        IdProcesso = Convert.ToInt32(reader["IdProcesso"]),
        CodProcesso = Str(reader, "CodProcesso"),
        CodArticolo = NullableString(reader, "CodArticolo"),
        Descrizione = Str(reader, "Descrizione"),
        Note = NullableString(reader, "Note"),
        Stato = Str(reader, "Stato")
    };

    private static VersioneProcessoDto ReadVersione(SqlDataReader reader) => new()
    {
        IdVersione = Convert.ToInt32(reader["IdVersione"]),
        IdProcesso = Convert.ToInt32(reader["IdProcesso"]),
        NumeroVersione = Convert.ToInt32(reader["NumeroVersione"]),
        Descrizione = NullableString(reader, "Descrizione"),
        Motivazione = NullableString(reader, "Motivazione"),
        ValidoDal = Convert.ToDateTime(reader["ValidoDal"]),
        ValidoAl = NullableDate(reader, "ValidoAl"),
        Stato = Str(reader, "Stato"),
        TempoAttesoMinuti = NullableDecimal(reader, "TempoAttesoMinuti"),
        SetupAttesoMinuti = NullableDecimal(reader, "SetupAttesoMinuti"),
        ProduttivitaAttesa = NullableDecimal(reader, "ProduttivitaAttesa"),
        CostoAtteso = NullableDecimal(reader, "CostoAtteso"),
        EnergiaAttesa = NullableDecimal(reader, "EnergiaAttesa")
    };

    private static FaseProcessoDto ReadFase(SqlDataReader reader) => new()
    {
        IdFase = Convert.ToInt32(reader["IdFase"]),
        IdVersione = Convert.ToInt32(reader["IdVersione"]),
        Sequenza = Convert.ToInt32(reader["Sequenza"]),
        CodFase = Str(reader, "CodFase"),
        Descrizione = Str(reader, "Descrizione"),
        IdLineaDefault = NullableInt(reader, "IdLineaDefault"),
        CodLinea = NullableString(reader, "CodLinea"),
        NomeLinea = NullableString(reader, "NomeLinea"),
        IdMacchinaDefault = NullableInt(reader, "IdMacchinaDefault"),
        CodMacchina = NullableString(reader, "CodMacchina"),
        NomeMacchina = NullableString(reader, "NomeMacchina"),
        TempoStandardMinuti = NullableDecimal(reader, "TempoStandardMinuti"),
        SetupStandardMinuti = NullableDecimal(reader, "SetupStandardMinuti"),
        ProduttivitaAttesa = NullableDecimal(reader, "ProduttivitaAttesa"),
        CostoStandard = NullableDecimal(reader, "CostoStandard"),
        EnergiaAttesa = NullableDecimal(reader, "EnergiaAttesa"),
        QualitaAttesa = NullableDecimal(reader, "QualitaAttesa"),
        ScartoAtteso = NullableDecimal(reader, "ScartoAtteso"),
        Note = NullableString(reader, "Note"),
        RichiedeMacchina = Bool(reader, "RichiedeMacchina", true),
        RichiedeTeam = Bool(reader, "RichiedeTeam", true),
        RichiedeSetup = Bool(reader, "RichiedeSetup", false),
        RichiedeOrari = Bool(reader, "RichiedeOrari", true),
        RichiedeArticolo = Bool(reader, "RichiedeArticolo", true),
        RichiedeLotto = Bool(reader, "RichiedeLotto", true),
        RichiedeComponenti = Bool(reader, "RichiedeComponenti", true),
        RichiedeControlloQualita = Bool(reader, "RichiedeControlloQualita", false),
        RichiedeNote = Bool(reader, "RichiedeNote", false),
        GeneraErp = Bool(reader, "GeneraErp", true),
        GeneraCaricoPf = Bool(reader, "GeneraCaricoPf", true),
        GeneraScaricoComponenti = Bool(reader, "GeneraScaricoComponenti", true)
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
    private static decimal? NullableDecimal(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToDecimal(reader[field]);
    private static DateTime? NullableDate(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToDateTime(reader[field]);
    private static bool Bool(SqlDataReader reader, string field, bool fallback) => HasColumn(reader, field) && reader[field] != DBNull.Value ? Convert.ToBoolean(reader[field]) : fallback;
    private static bool HasColumn(SqlDataReader reader, string field) { for (var i = 0; i < reader.FieldCount; i++) if (string.Equals(reader.GetName(i), field, StringComparison.OrdinalIgnoreCase)) return true; return false; }
}

public sealed class ProcessoDto
{
    public int IdProcesso { get; set; }
    public string CodProcesso { get; set; } = "";
    public string? CodArticolo { get; set; }
    public string Descrizione { get; set; } = "";
    public string? Note { get; set; }
    public string Stato { get; set; } = "";
    public int? IdVersioneCorrente { get; set; }
    public int? NumeroVersioneCorrente { get; set; }
    public DateTime? ValidoDal { get; set; }
    public DateTime? ValidoAl { get; set; }
}

public sealed class ProcessoRequest
{
    public int? IdProcesso { get; set; }
    public string CodProcesso { get; set; } = "";
    public string? CodArticolo { get; set; }
    public string Descrizione { get; set; } = "";
    public string? Note { get; set; }
    public string Stato { get; set; } = "BOZZA";
}

public sealed class VersioneProcessoDto
{
    public int IdVersione { get; set; }
    public int IdProcesso { get; set; }
    public int NumeroVersione { get; set; }
    public string? Descrizione { get; set; }
    public string? Motivazione { get; set; }
    public DateTime ValidoDal { get; set; }
    public DateTime? ValidoAl { get; set; }
    public string Stato { get; set; } = "";
    public decimal? TempoAttesoMinuti { get; set; }
    public decimal? SetupAttesoMinuti { get; set; }
    public decimal? ProduttivitaAttesa { get; set; }
    public decimal? CostoAtteso { get; set; }
    public decimal? EnergiaAttesa { get; set; }
}

public sealed class VersioneProcessoRequest
{
    public int? IdVersione { get; set; }
    public int? NumeroVersione { get; set; }
    public string? Descrizione { get; set; }
    public string? Motivazione { get; set; }
    public DateTime ValidoDal { get; set; }
    public DateTime? ValidoAl { get; set; }
    public string Stato { get; set; } = "BOZZA";
    public decimal? TempoAttesoMinuti { get; set; }
    public decimal? SetupAttesoMinuti { get; set; }
    public decimal? ProduttivitaAttesa { get; set; }
    public decimal? CostoAtteso { get; set; }
    public decimal? EnergiaAttesa { get; set; }
}

public sealed class FaseProcessoDto
{
    public int IdFase { get; set; }
    public int IdVersione { get; set; }
    public int Sequenza { get; set; }
    public string CodFase { get; set; } = "";
    public string Descrizione { get; set; } = "";
    public int? IdLineaDefault { get; set; }
    public string? CodLinea { get; set; }
    public string? NomeLinea { get; set; }
    public int? IdMacchinaDefault { get; set; }
    public string? CodMacchina { get; set; }
    public string? NomeMacchina { get; set; }
    public decimal? TempoStandardMinuti { get; set; }
    public decimal? SetupStandardMinuti { get; set; }
    public decimal? ProduttivitaAttesa { get; set; }
    public decimal? CostoStandard { get; set; }
    public decimal? EnergiaAttesa { get; set; }
    public decimal? QualitaAttesa { get; set; }
    public decimal? ScartoAtteso { get; set; }
    public string? Note { get; set; }
    public bool RichiedeMacchina { get; set; } = true;
    public bool RichiedeTeam { get; set; } = true;
    public bool RichiedeSetup { get; set; }
    public bool RichiedeOrari { get; set; } = true;
    public bool RichiedeArticolo { get; set; } = true;
    public bool RichiedeLotto { get; set; } = true;
    public bool RichiedeComponenti { get; set; } = true;
    public bool RichiedeControlloQualita { get; set; }
    public bool RichiedeNote { get; set; }
    public bool GeneraErp { get; set; } = true;
    public bool GeneraCaricoPf { get; set; } = true;
    public bool GeneraScaricoComponenti { get; set; } = true;}

public sealed class FaseProcessoRequest
{
    public int? IdFase { get; set; }
    public int Sequenza { get; set; }
    public string CodFase { get; set; } = "";
    public string Descrizione { get; set; } = "";
    public int? IdLineaDefault { get; set; }
    public int? IdMacchinaDefault { get; set; }
    public decimal? TempoStandardMinuti { get; set; }
    public decimal? SetupStandardMinuti { get; set; }
    public decimal? ProduttivitaAttesa { get; set; }
    public decimal? CostoStandard { get; set; }
    public decimal? EnergiaAttesa { get; set; }
    public decimal? QualitaAttesa { get; set; }
    public decimal? ScartoAtteso { get; set; }
    public string? Note { get; set; }
    public bool RichiedeMacchina { get; set; } = true;
    public bool RichiedeTeam { get; set; } = true;
    public bool RichiedeSetup { get; set; }
    public bool RichiedeOrari { get; set; } = true;
    public bool RichiedeArticolo { get; set; } = true;
    public bool RichiedeLotto { get; set; } = true;
    public bool RichiedeComponenti { get; set; } = true;
    public bool RichiedeControlloQualita { get; set; }
    public bool RichiedeNote { get; set; }
    public bool GeneraErp { get; set; } = true;
    public bool GeneraCaricoPf { get; set; } = true;
    public bool GeneraScaricoComponenti { get; set; } = true;}

public sealed class FaseRisorsaDto
{
    public int IdFaseRisorsa { get; set; }
    public int IdFase { get; set; }
    public int? IdLinea { get; set; }
    public string? CodLinea { get; set; }
    public string? NomeLinea { get; set; }
    public int? IdMacchina { get; set; }
    public string? CodMacchina { get; set; }
    public string? NomeMacchina { get; set; }
    public int? IdTeam { get; set; }
    public string? CodTeam { get; set; }
    public string? TeamDescrizione { get; set; }
    public DateTime ValidoDal { get; set; }
    public DateTime? ValidoAl { get; set; }
    public decimal? VelocitaReale { get; set; }
    public decimal? TempoSetupAggiuntivoMinuti { get; set; }
    public decimal? ScartoMedio { get; set; }
    public decimal? EnergiaAggiuntiva { get; set; }
    public int? OperatoriMinimi { get; set; }
    public int? OperatoriConsigliati { get; set; }
    public string? CompetenzeRichieste { get; set; }
    public string? Note { get; set; }
}

public sealed class FaseRisorsaRequest
{
    public int? IdFaseRisorsa { get; set; }
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public int? IdTeam { get; set; }
    public DateTime ValidoDal { get; set; }
    public DateTime? ValidoAl { get; set; }
    public decimal? VelocitaReale { get; set; }
    public decimal? TempoSetupAggiuntivoMinuti { get; set; }
    public decimal? ScartoMedio { get; set; }
    public decimal? EnergiaAggiuntiva { get; set; }
    public int? OperatoriMinimi { get; set; }
    public int? OperatoriConsigliati { get; set; }
    public string? CompetenzeRichieste { get; set; }
    public string? Note { get; set; }
}






