using System.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;

namespace FactoryFlow.Api.Controllers;

[ApiController]
public sealed class ParametriOperativiController : ControllerBase
{
    private readonly string _connectionString;

    public ParametriOperativiController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    [HttpGet("api/macchine")]
    public async Task<ActionResult<List<MacchinaDto>>> GetMacchine(CancellationToken ct)
    {
        var result = new List<MacchinaDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_Macchine_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadMacchina(reader));
        return Ok(result);
    }

    [HttpPost("api/macchine")]
    public async Task<ActionResult> CreateMacchina([FromBody] MacchinaRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CodMacchina) || string.IsNullOrWhiteSpace(request.NomeMacchina)) return BadRequest("Codice e nome macchina obbligatori.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_Macchine_Save");
        cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
        cmd.Parameters.Add("@CodMacchina", SqlDbType.VarChar, 30).Value = request.CodMacchina.Trim();
        cmd.Parameters.Add("@NomeMacchina", SqlDbType.VarChar, 100).Value = request.NomeMacchina.Trim();
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 255).Value = DbValue(request.Descrizione, 255);
        cmd.Parameters.Add("@Reparto", SqlDbType.VarChar, 100).Value = DbValue(request.Reparto, 100);
        cmd.Parameters.Add("@Costruttore", SqlDbType.VarChar, 100).Value = DbValue(request.Costruttore, 100);
        cmd.Parameters.Add("@Modello", SqlDbType.VarChar, 100).Value = DbValue(request.Modello, 100);
        cmd.Parameters.Add("@Matricola", SqlDbType.VarChar, 100).Value = DbValue(request.Matricola, 100);
        cmd.Parameters.Add("@AnnoInstallazione", SqlDbType.Int).Value = request.AnnoInstallazione.HasValue ? request.AnnoInstallazione.Value : DBNull.Value;
        cmd.Parameters.Add("@Stato", SqlDbType.VarChar, 30).Value = DbValue(request.Stato, 30);
        cmd.Parameters.Add("@UnitaMisuraPrincipale", SqlDbType.VarChar, 10).Value = DbValue(request.UnitaMisuraPrincipale, 10);
        AddDecimal(cmd, "@VelocitaNominale", request.VelocitaNominale, 18, 6);
        AddDecimal(cmd, "@VelocitaOttimale", request.VelocitaOttimale, 18, 6);
        AddDecimal(cmd, "@VelocitaMassima", request.VelocitaMassima, 18, 6);
        AddDecimal(cmd, "@CapacitaMassimaTurno", request.CapacitaMassimaTurno, 18, 6);
        AddDecimal(cmd, "@CapacitaMassimaGiornaliera", request.CapacitaMassimaGiornaliera, 18, 6);
        AddDecimal(cmd, "@CapacitaMassimaSettimanale", request.CapacitaMassimaSettimanale, 18, 6);
        AddDecimal(cmd, "@TempoMinimoLottoMinuti", request.TempoMinimoLottoMinuti, 18, 3);
        AddDecimal(cmd, "@TempoMassimoLottoMinuti", request.TempoMassimoLottoMinuti, 18, 3);
        AddDecimal(cmd, "@CostoAmmortamentoOra", request.CostoAmmortamentoOra, 18, 4);
        AddDecimal(cmd, "@CostoManutenzioneOra", request.CostoManutenzioneOra, 18, 4);
        AddDecimal(cmd, "@CostoEnergiaVuotoOra", request.CostoEnergiaVuotoOra, 18, 4);
        AddDecimal(cmd, "@CostoEnergiaProduzioneOra", request.CostoEnergiaProduzioneOra, 18, 4);
        AddDecimal(cmd, "@CostoLubrificantiOra", request.CostoLubrificantiOra, 18, 4);
        AddDecimal(cmd, "@CostoUtensiliOra", request.CostoUtensiliOra, 18, 4);
        AddDecimal(cmd, "@CostoPuliziaOra", request.CostoPuliziaOra, 18, 4);
        AddDecimal(cmd, "@CostoFermoMacchinaOra", request.CostoFermoMacchinaOra, 18, 4);
        AddDecimal(cmd, "@CostoOccupazioneSpazioOra", request.CostoOccupazioneSpazioOra, 18, 4);
        AddDecimal(cmd, "@TempoRiscaldamentoMinuti", request.TempoRiscaldamentoMinuti, 18, 3);
        AddDecimal(cmd, "@TempoRaffreddamentoMinuti", request.TempoRaffreddamentoMinuti, 18, 3);
        AddDecimal(cmd, "@TempoCambioFormatoStandardMinuti", request.TempoCambioFormatoStandardMinuti, 18, 3);
        AddDecimal(cmd, "@TempoPuliziaStandardMinuti", request.TempoPuliziaStandardMinuti, 18, 3);
        AddDecimal(cmd, "@TempoSanificazioneMinuti", request.TempoSanificazioneMinuti, 18, 3);
        AddDecimal(cmd, "@TempoSetupBaseMinuti", request.TempoSetupBaseMinuti, 18, 3);
        AddDecimal(cmd, "@TempoAvviamentoMinuti", request.TempoAvviamentoMinuti, 18, 3);
        AddDecimal(cmd, "@TempoArrestoMinuti", request.TempoArrestoMinuti, 18, 3);
        AddDecimal(cmd, "@ConsumoKwSpunto", request.ConsumoKwSpunto, 18, 4);
        AddDecimal(cmd, "@ConsumoKwFunzione", request.ConsumoKwFunzione, 18, 4);
        AddDecimal(cmd, "@UnitaMinutoBenchmark", request.UnitaMinutoBenchmark, 18, 6);
        cmd.Parameters.Add("@NoteTecniche", SqlDbType.VarChar, 500).Value = DbValue(request.NoteTecniche, 500);
        cmd.Parameters.Add("@Attiva", SqlDbType.Bit).Value = request.Attiva;
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    [HttpGet("api/setup-tipi")]
    public async Task<ActionResult<List<SetupTipoDto>>> GetSetupTipi(CancellationToken ct)
    {
        var result = new List<SetupTipoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_SetupTipi_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(new SetupTipoDto { IdSetupTipo = Convert.ToInt32(reader["IdSetupTipo"]), CodSetupTipo = Str(reader, "CodSetupTipo"), Descrizione = Str(reader, "Descrizione"), Attivo = Convert.ToBoolean(reader["Attivo"]) });
        return Ok(result);
    }

    [HttpPost("api/setup-tipi")]
    public async Task<ActionResult> CreateSetupTipo([FromBody] SetupTipoRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CodSetupTipo) || string.IsNullOrWhiteSpace(request.Descrizione)) return BadRequest("Codice e descrizione setup obbligatori.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_SetupTipi_Save");
        cmd.Parameters.Add("@IdSetupTipo", SqlDbType.Int).Value = request.IdSetupTipo.HasValue ? request.IdSetupTipo.Value : DBNull.Value;
        cmd.Parameters.Add("@CodSetupTipo", SqlDbType.VarChar, 30).Value = request.CodSetupTipo.Trim();
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 150).Value = request.Descrizione.Trim();
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    [HttpGet("api/setup-regole")]
    public async Task<ActionResult<List<SetupRegolaDto>>> GetSetupRegole(CancellationToken ct)
    {
        var result = new List<SetupRegolaDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_SetupRegole_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadSetupRegola(reader));
        return Ok(result);
    }

    [HttpPost("api/setup-regole")]
    public async Task<ActionResult> CreateSetupRegola([FromBody] SetupRegolaRequest request, CancellationToken ct)
    {
        if (request.IdSetupTipo <= 0) return BadRequest("Tipo setup obbligatorio.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_SetupRegole_Save");
        cmd.Parameters.Add("@IdSetupRegola", SqlDbType.Int).Value = request.IdSetupRegola.HasValue ? request.IdSetupRegola.Value : DBNull.Value;
        cmd.Parameters.Add("@IdSetupTipo", SqlDbType.Int).Value = request.IdSetupTipo;
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea.HasValue ? request.IdLinea.Value : DBNull.Value;
        cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
        cmd.Parameters.Add("@CodArticolo", SqlDbType.VarChar, 20).Value = DbValue(request.CodArticolo, 20);
        AddDecimal(cmd, "@TempoStandardMinuti", request.TempoStandardMinuti, 18, 3);
        AddDecimal(cmd, "@CostoStandard", request.CostoStandard, 18, 4);
        cmd.Parameters.Add("@Priorita", SqlDbType.Int).Value = request.Priorita;
        cmd.Parameters.Add("@Attiva", SqlDbType.Bit).Value = request.Attiva;
        cmd.Parameters.Add("@ValidoDal", SqlDbType.Date).Value = request.ValidoDal.HasValue ? request.ValidoDal.Value.Date : (object)DBNull.Value;
        cmd.Parameters.Add("@ValidoAl", SqlDbType.Date).Value = request.ValidoAl.HasValue ? request.ValidoAl.Value.Date : (!request.Attiva ? DateTime.Today : (object)DBNull.Value);
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    [HttpGet("api/team-operativi")]
    public async Task<ActionResult<List<TeamOperativoDto>>> GetTeamOperativi(CancellationToken ct)
    {
        var result = new List<TeamOperativoDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_TeamOperativi_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(new TeamOperativoDto { IdTeam = Convert.ToInt32(reader["IdTeam"]), CodTeam = Str(reader, "CodTeam"), Descrizione = Str(reader, "Descrizione"), Note = NullableString(reader, "Note"), Attivo = Convert.ToBoolean(reader["Attivo"]) });
        return Ok(result);
    }

    [HttpPost("api/team-operativi")]
    public async Task<ActionResult> CreateTeamOperativo([FromBody] TeamOperativoRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.CodTeam) || string.IsNullOrWhiteSpace(request.Descrizione)) return BadRequest("Codice e descrizione team obbligatori.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_TeamOperativi_Save");
        cmd.Parameters.Add("@IdTeam", SqlDbType.Int).Value = request.IdTeam.HasValue ? request.IdTeam.Value : DBNull.Value;
        cmd.Parameters.Add("@CodTeam", SqlDbType.VarChar, 30).Value = request.CodTeam.Trim();
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 150).Value = request.Descrizione.Trim();
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 255).Value = DbValue(request.Note, 255);
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    [HttpGet("api/team-operativi/{idTeam:int}/operatori")]
    public async Task<ActionResult<List<TeamOperatoreDto>>> GetTeamOperatori(int idTeam, CancellationToken ct)
    {
        var result = new List<TeamOperatoreDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_TeamOperatori_List");
        cmd.Parameters.Add("@IdTeam", SqlDbType.Int).Value = idTeam;
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadTeamOperatore(reader));
        return Ok(result);
    }

    [HttpPost("api/team-operativi/{idTeam:int}/operatori")]
    public async Task<ActionResult> CreateTeamOperatore(int idTeam, [FromBody] TeamOperatoreRequest request, CancellationToken ct)
    {
        if (request.IdOperatore <= 0) return BadRequest("Operatore obbligatorio.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_TeamOperatori_Save");
        cmd.Parameters.Add("@IdTeamOperatore", SqlDbType.Int).Value = request.IdTeamOperatore.HasValue ? request.IdTeamOperatore.Value : DBNull.Value;
        cmd.Parameters.Add("@IdTeam", SqlDbType.Int).Value = idTeam;
        cmd.Parameters.Add("@IdOperatore", SqlDbType.Int).Value = request.IdOperatore;
        cmd.Parameters.Add("@IdRuoloOperativo", SqlDbType.Int).Value = request.IdRuoloOperativo.HasValue ? request.IdRuoloOperativo.Value : DBNull.Value;
        AddDecimal(cmd, "@CostoOrarioApplicato", request.CostoOrarioApplicato, 18, 4);
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 255).Value = DbValue(request.Note, 255);
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        cmd.Parameters.Add("@ValidoDal", SqlDbType.Date).Value = request.ValidoDal.HasValue ? request.ValidoDal.Value.Date : (object)DBNull.Value;
        cmd.Parameters.Add("@ValidoAl", SqlDbType.Date).Value = request.ValidoAl.HasValue ? request.ValidoAl.Value.Date : (!request.Attivo ? DateTime.Today : (object)DBNull.Value);
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    [HttpGet("api/costi-linea")]
    public async Task<ActionResult<List<CostoLineaDto>>> GetCostiLinea(CancellationToken ct)
    {
        var result = new List<CostoLineaDto>();
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_CostiLinea_List");
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct)) result.Add(ReadCostoLinea(reader));
        return Ok(result);
    }

    [HttpPost("api/costi-linea")]
    public async Task<ActionResult> CreateCostoLinea([FromBody] CostoLineaRequest request, CancellationToken ct)
    {
        if (request.IdLinea <= 0) return BadRequest("Linea obbligatoria.");
        await using var conn = new SqlConnection(_connectionString);
        await using var cmd = Stored(conn, "dbo.sp_FF_CostiLinea_Save");
        cmd.Parameters.Add("@IdCostoLinea", SqlDbType.Int).Value = DBNull.Value;
        cmd.Parameters.Add("@IdLinea", SqlDbType.Int).Value = request.IdLinea;
        cmd.Parameters.Add("@IdMacchina", SqlDbType.Int).Value = request.IdMacchina.HasValue ? request.IdMacchina.Value : DBNull.Value;
        cmd.Parameters.Add("@ValidoDal", SqlDbType.Date).Value = request.ValidoDal.Date;
        cmd.Parameters.Add("@ValidoAl", SqlDbType.Date).Value = request.ValidoAl.HasValue ? request.ValidoAl.Value.Date : DBNull.Value;
        AddDecimal(cmd, "@CostoFissoOra", request.CostoFissoOra, 18, 4);
        AddDecimal(cmd, "@CostoMacchinaOra", request.CostoMacchinaOra, 18, 4);
        AddDecimal(cmd, "@CostoManodoperaOra", request.CostoManodoperaOra, 18, 4);
        AddDecimal(cmd, "@CostoEnergiaOra", request.CostoEnergiaOra, 18, 4);
        AddDecimal(cmd, "@CostoEnergiaUnita", request.CostoEnergiaUnita, 18, 6);
        cmd.Parameters.Add("@Note", SqlDbType.VarChar, 255).Value = DbValue(request.Note, 255);
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        await conn.OpenAsync(ct);
        await cmd.ExecuteNonQueryAsync(ct);
        return NoContent();
    }

    private static SqlCommand Stored(SqlConnection conn, string name) => new(name, conn) { CommandType = CommandType.StoredProcedure };

    private static MacchinaDto ReadMacchina(SqlDataReader reader) => new()
    {
        IdMacchina = Convert.ToInt32(reader["IdMacchina"]), IdLinea = NullableInt(reader, "IdLinea"), CodLinea = NullableString(reader, "CodLinea"), NomeLinea = NullableString(reader, "NomeLinea"), CodMacchina = Str(reader, "CodMacchina"), NomeMacchina = Str(reader, "NomeMacchina"), Descrizione = NullableString(reader, "Descrizione"), Reparto = NullableString(reader, "Reparto"), Costruttore = NullableString(reader, "Costruttore"), Modello = NullableString(reader, "Modello"), Matricola = NullableString(reader, "Matricola"), AnnoInstallazione = NullableInt(reader, "AnnoInstallazione"), Stato = NullableString(reader, "Stato"), UnitaMisuraPrincipale = NullableString(reader, "UnitaMisuraPrincipale"), VelocitaNominale = NullableDecimal(reader, "VelocitaNominale"), VelocitaOttimale = NullableDecimal(reader, "VelocitaOttimale"), VelocitaMassima = NullableDecimal(reader, "VelocitaMassima"), CapacitaMassimaTurno = NullableDecimal(reader, "CapacitaMassimaTurno"), CapacitaMassimaGiornaliera = NullableDecimal(reader, "CapacitaMassimaGiornaliera"), CapacitaMassimaSettimanale = NullableDecimal(reader, "CapacitaMassimaSettimanale"), TempoMinimoLottoMinuti = NullableDecimal(reader, "TempoMinimoLottoMinuti"), TempoMassimoLottoMinuti = NullableDecimal(reader, "TempoMassimoLottoMinuti"), CostoAmmortamentoOra = NullableDecimal(reader, "CostoAmmortamentoOra"), CostoManutenzioneOra = NullableDecimal(reader, "CostoManutenzioneOra"), CostoEnergiaVuotoOra = NullableDecimal(reader, "CostoEnergiaVuotoOra"), CostoEnergiaProduzioneOra = NullableDecimal(reader, "CostoEnergiaProduzioneOra"), CostoLubrificantiOra = NullableDecimal(reader, "CostoLubrificantiOra"), CostoUtensiliOra = NullableDecimal(reader, "CostoUtensiliOra"), CostoPuliziaOra = NullableDecimal(reader, "CostoPuliziaOra"), CostoFermoMacchinaOra = NullableDecimal(reader, "CostoFermoMacchinaOra"), CostoOccupazioneSpazioOra = NullableDecimal(reader, "CostoOccupazioneSpazioOra"), TempoRiscaldamentoMinuti = NullableDecimal(reader, "TempoRiscaldamentoMinuti"), TempoRaffreddamentoMinuti = NullableDecimal(reader, "TempoRaffreddamentoMinuti"), TempoCambioFormatoStandardMinuti = NullableDecimal(reader, "TempoCambioFormatoStandardMinuti"), TempoPuliziaStandardMinuti = NullableDecimal(reader, "TempoPuliziaStandardMinuti"), TempoSanificazioneMinuti = NullableDecimal(reader, "TempoSanificazioneMinuti"), TempoSetupBaseMinuti = NullableDecimal(reader, "TempoSetupBaseMinuti"), TempoAvviamentoMinuti = NullableDecimal(reader, "TempoAvviamentoMinuti"), TempoArrestoMinuti = NullableDecimal(reader, "TempoArrestoMinuti"), ConsumoKwSpunto = NullableDecimal(reader, "ConsumoKwSpunto"), ConsumoKwFunzione = NullableDecimal(reader, "ConsumoKwFunzione"), UnitaMinutoBenchmark = NullableDecimal(reader, "UnitaMinutoBenchmark"), NoteTecniche = NullableString(reader, "NoteTecniche"), Attiva = Convert.ToBoolean(reader["Attiva"])
    };

    private static SetupRegolaDto ReadSetupRegola(SqlDataReader reader) => new()
    {
        IdSetupRegola = Convert.ToInt32(reader["IdSetupRegola"]), IdSetupTipo = Convert.ToInt32(reader["IdSetupTipo"]), CodSetupTipo = Str(reader, "CodSetupTipo"), SetupDescrizione = Str(reader, "SetupDescrizione"), IdLinea = NullableInt(reader, "IdLinea"), CodLinea = NullableString(reader, "CodLinea"), NomeLinea = NullableString(reader, "NomeLinea"), IdMacchina = NullableInt(reader, "IdMacchina"), CodMacchina = NullableString(reader, "CodMacchina"), NomeMacchina = NullableString(reader, "NomeMacchina"), CodArticolo = NullableString(reader, "CodArticolo"), TempoStandardMinuti = NullableDecimal(reader, "TempoStandardMinuti"), CostoStandard = NullableDecimal(reader, "CostoStandard"), Priorita = Convert.ToInt32(reader["Priorita"]), ValidoDal = NullableDate(reader, "ValidoDal"), ValidoAl = NullableDate(reader, "ValidoAl"), Attiva = Convert.ToBoolean(reader["Attiva"])
    };

    private static TeamOperatoreDto ReadTeamOperatore(SqlDataReader reader) => new()
    {
        IdTeamOperatore = Convert.ToInt32(reader["IdTeamOperatore"]), IdTeam = Convert.ToInt32(reader["IdTeam"]), IdOperatore = Convert.ToInt32(reader["IdOperatore"]), CodOperatore = Str(reader, "CodOperatore"), Nome = Str(reader, "Nome"), Cognome = NullableString(reader, "Cognome"), IdRuoloOperativo = NullableInt(reader, "IdRuoloOperativo"), CodRuolo = NullableString(reader, "CodRuolo"), RuoloDescrizione = NullableString(reader, "RuoloDescrizione"), CostoOrarioApplicato = NullableDecimal(reader, "CostoOrarioApplicato"), Note = NullableString(reader, "Note"), ValidoDal = NullableDate(reader, "ValidoDal"), ValidoAl = NullableDate(reader, "ValidoAl"), Attivo = Convert.ToBoolean(reader["Attivo"])
    };

    private static CostoLineaDto ReadCostoLinea(SqlDataReader reader) => new()
    {
        IdCostoLinea = Convert.ToInt32(reader["IdCostoLinea"]), IdLinea = Convert.ToInt32(reader["IdLinea"]), CodLinea = Str(reader, "CodLinea"), NomeLinea = Str(reader, "NomeLinea"), IdMacchina = NullableInt(reader, "IdMacchina"), CodMacchina = NullableString(reader, "CodMacchina"), NomeMacchina = NullableString(reader, "NomeMacchina"), ValidoDal = Convert.ToDateTime(reader["ValidoDal"]), ValidoAl = reader["ValidoAl"] == DBNull.Value ? null : Convert.ToDateTime(reader["ValidoAl"]), CostoFissoOra = NullableDecimal(reader, "CostoFissoOra"), CostoMacchinaOra = NullableDecimal(reader, "CostoMacchinaOra"), CostoManodoperaOra = NullableDecimal(reader, "CostoManodoperaOra"), CostoEnergiaOra = NullableDecimal(reader, "CostoEnergiaOra"), CostoEnergiaUnita = NullableDecimal(reader, "CostoEnergiaUnita"), Note = NullableString(reader, "Note"), Attivo = Convert.ToBoolean(reader["Attivo"])
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
}

public sealed class MacchinaDto { public int IdMacchina { get; set; } public int? IdLinea { get; set; } public string? CodLinea { get; set; } public string? NomeLinea { get; set; } public string CodMacchina { get; set; } = ""; public string NomeMacchina { get; set; } = ""; public string? Descrizione { get; set; } public string? Reparto { get; set; } public string? Costruttore { get; set; } public string? Modello { get; set; } public string? Matricola { get; set; } public int? AnnoInstallazione { get; set; } public string? Stato { get; set; } public string? UnitaMisuraPrincipale { get; set; } public decimal? VelocitaNominale { get; set; } public decimal? VelocitaOttimale { get; set; } public decimal? VelocitaMassima { get; set; } public decimal? CapacitaMassimaTurno { get; set; } public decimal? CapacitaMassimaGiornaliera { get; set; } public decimal? CapacitaMassimaSettimanale { get; set; } public decimal? TempoMinimoLottoMinuti { get; set; } public decimal? TempoMassimoLottoMinuti { get; set; } public decimal? CostoAmmortamentoOra { get; set; } public decimal? CostoManutenzioneOra { get; set; } public decimal? CostoEnergiaVuotoOra { get; set; } public decimal? CostoEnergiaProduzioneOra { get; set; } public decimal? CostoLubrificantiOra { get; set; } public decimal? CostoUtensiliOra { get; set; } public decimal? CostoPuliziaOra { get; set; } public decimal? CostoFermoMacchinaOra { get; set; } public decimal? CostoOccupazioneSpazioOra { get; set; } public decimal? TempoRiscaldamentoMinuti { get; set; } public decimal? TempoRaffreddamentoMinuti { get; set; } public decimal? TempoCambioFormatoStandardMinuti { get; set; } public decimal? TempoPuliziaStandardMinuti { get; set; } public decimal? TempoSanificazioneMinuti { get; set; } public decimal? TempoSetupBaseMinuti { get; set; } public decimal? TempoAvviamentoMinuti { get; set; } public decimal? TempoArrestoMinuti { get; set; } public decimal? ConsumoKwSpunto { get; set; } public decimal? ConsumoKwFunzione { get; set; } public decimal? UnitaMinutoBenchmark { get; set; } public string? NoteTecniche { get; set; } public bool Attiva { get; set; } }
public sealed class MacchinaRequest { public int? IdMacchina { get; set; } public int? IdLinea { get; set; } public string CodMacchina { get; set; } = ""; public string NomeMacchina { get; set; } = ""; public string? Descrizione { get; set; } public string? Reparto { get; set; } public string? Costruttore { get; set; } public string? Modello { get; set; } public string? Matricola { get; set; } public int? AnnoInstallazione { get; set; } public string? Stato { get; set; } public string? UnitaMisuraPrincipale { get; set; } public decimal? VelocitaNominale { get; set; } public decimal? VelocitaOttimale { get; set; } public decimal? VelocitaMassima { get; set; } public decimal? CapacitaMassimaTurno { get; set; } public decimal? CapacitaMassimaGiornaliera { get; set; } public decimal? CapacitaMassimaSettimanale { get; set; } public decimal? TempoMinimoLottoMinuti { get; set; } public decimal? TempoMassimoLottoMinuti { get; set; } public decimal? CostoAmmortamentoOra { get; set; } public decimal? CostoManutenzioneOra { get; set; } public decimal? CostoEnergiaVuotoOra { get; set; } public decimal? CostoEnergiaProduzioneOra { get; set; } public decimal? CostoLubrificantiOra { get; set; } public decimal? CostoUtensiliOra { get; set; } public decimal? CostoPuliziaOra { get; set; } public decimal? CostoFermoMacchinaOra { get; set; } public decimal? CostoOccupazioneSpazioOra { get; set; } public decimal? TempoRiscaldamentoMinuti { get; set; } public decimal? TempoRaffreddamentoMinuti { get; set; } public decimal? TempoCambioFormatoStandardMinuti { get; set; } public decimal? TempoPuliziaStandardMinuti { get; set; } public decimal? TempoSanificazioneMinuti { get; set; } public decimal? TempoSetupBaseMinuti { get; set; } public decimal? TempoAvviamentoMinuti { get; set; } public decimal? TempoArrestoMinuti { get; set; } public decimal? ConsumoKwSpunto { get; set; } public decimal? ConsumoKwFunzione { get; set; } public decimal? UnitaMinutoBenchmark { get; set; } public string? NoteTecniche { get; set; } public bool Attiva { get; set; } = true; }
public sealed class SetupTipoDto { public int IdSetupTipo { get; set; } public string CodSetupTipo { get; set; } = ""; public string Descrizione { get; set; } = ""; public bool Attivo { get; set; } }
public sealed class SetupTipoRequest { public int? IdSetupTipo { get; set; } public string CodSetupTipo { get; set; } = ""; public string Descrizione { get; set; } = ""; public bool Attivo { get; set; } = true; }
public sealed class SetupRegolaDto { public int IdSetupRegola { get; set; } public int IdSetupTipo { get; set; } public string CodSetupTipo { get; set; } = ""; public string SetupDescrizione { get; set; } = ""; public int? IdLinea { get; set; } public string? CodLinea { get; set; } public string? NomeLinea { get; set; } public int? IdMacchina { get; set; } public string? CodMacchina { get; set; } public string? NomeMacchina { get; set; } public string? CodArticolo { get; set; } public decimal? TempoStandardMinuti { get; set; } public decimal? CostoStandard { get; set; } public int Priorita { get; set; } public DateTime? ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public bool Attiva { get; set; } }
public sealed class SetupRegolaRequest { public int? IdSetupRegola { get; set; } public int IdSetupTipo { get; set; } public int? IdLinea { get; set; } public int? IdMacchina { get; set; } public string? CodArticolo { get; set; } public decimal? TempoStandardMinuti { get; set; } public decimal? CostoStandard { get; set; } public int Priorita { get; set; } = 100; public DateTime? ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public bool Attiva { get; set; } = true; }
public sealed class TeamOperativoDto { public int IdTeam { get; set; } public string CodTeam { get; set; } = ""; public string Descrizione { get; set; } = ""; public string? Note { get; set; } public bool Attivo { get; set; } }
public sealed class TeamOperativoRequest { public int? IdTeam { get; set; } public string CodTeam { get; set; } = ""; public string Descrizione { get; set; } = ""; public string? Note { get; set; } public bool Attivo { get; set; } = true; }
public sealed class TeamOperatoreDto { public int IdTeamOperatore { get; set; } public int IdTeam { get; set; } public int IdOperatore { get; set; } public string CodOperatore { get; set; } = ""; public string Nome { get; set; } = ""; public string? Cognome { get; set; } public int? IdRuoloOperativo { get; set; } public string? CodRuolo { get; set; } public string? RuoloDescrizione { get; set; } public decimal? CostoOrarioApplicato { get; set; } public string? Note { get; set; } public DateTime? ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public bool Attivo { get; set; } }
public sealed class TeamOperatoreRequest { public int? IdTeamOperatore { get; set; } public int IdOperatore { get; set; } public int? IdRuoloOperativo { get; set; } public decimal? CostoOrarioApplicato { get; set; } public string? Note { get; set; } public DateTime? ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public bool Attivo { get; set; } = true; }
public sealed class CostoLineaDto { public int IdCostoLinea { get; set; } public int IdLinea { get; set; } public string CodLinea { get; set; } = ""; public string NomeLinea { get; set; } = ""; public int? IdMacchina { get; set; } public string? CodMacchina { get; set; } public string? NomeMacchina { get; set; } public DateTime ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public decimal? CostoFissoOra { get; set; } public decimal? CostoMacchinaOra { get; set; } public decimal? CostoManodoperaOra { get; set; } public decimal? CostoEnergiaOra { get; set; } public decimal? CostoEnergiaUnita { get; set; } public string? Note { get; set; } public bool Attivo { get; set; } }
public sealed class CostoLineaRequest { public int? IdCostoLinea { get; set; } public int IdLinea { get; set; } public int? IdMacchina { get; set; } public DateTime ValidoDal { get; set; } public DateTime? ValidoAl { get; set; } public decimal? CostoFissoOra { get; set; } public decimal? CostoMacchinaOra { get; set; } public decimal? CostoManodoperaOra { get; set; } public decimal? CostoEnergiaOra { get; set; } public decimal? CostoEnergiaUnita { get; set; } public string? Note { get; set; } public bool Attivo { get; set; } = true; }









