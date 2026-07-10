using System.Data;
using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Operatori;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace FactoryFlow.Infrastructure.Repositories;

public sealed class OperatoriRepository : IOperatoriRepository
{
    private readonly string _farmFlowConnectionString;

    public OperatoriRepository(IConfiguration configuration)
    {
        _farmFlowConnectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    public async Task<List<OperatoreDto>> GetOperatoriAsync(CancellationToken ct = default)
    {
        var result = new List<OperatoreDto>();
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_Operatori_List", conn) { CommandType = CommandType.StoredProcedure };
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            result.Add(ReadOperatore(reader));
        return result;
    }

    public async Task<OperatoreDto> CreateOperatoreAsync(OperatoreRequestDto request, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_Operatori_Save", conn) { CommandType = CommandType.StoredProcedure };
        AddOperatoreParameters(cmd, request);
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return ReadOperatore(reader);
    }

    public async Task<List<RuoloOperativoDto>> GetRuoliAsync(CancellationToken ct = default)
    {
        var result = new List<RuoloOperativoDto>();
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_RuoliOperativi_List", conn) { CommandType = CommandType.StoredProcedure };
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            result.Add(ReadRuolo(reader));
        return result;
    }

    public async Task<RuoloOperativoDto> CreateRuoloAsync(RuoloOperativoRequestDto request, CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_RuoliOperativi_Save", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.Add("@IdRuoloOperativo", SqlDbType.Int).Value = request.IdRuoloOperativo.HasValue ? request.IdRuoloOperativo.Value : DBNull.Value;
        cmd.Parameters.Add("@CodRuolo", SqlDbType.VarChar, 20).Value = request.CodRuolo.Trim();
        cmd.Parameters.Add("@Descrizione", SqlDbType.VarChar, 100).Value = request.Descrizione.Trim();
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);
        await reader.ReadAsync(ct);
        return ReadRuolo(reader);
    }

    private static void AddOperatoreParameters(SqlCommand cmd, OperatoreRequestDto request)
    {
        cmd.Parameters.Add("@IdOperatore", SqlDbType.Int).Value = request.IdOperatore.HasValue ? request.IdOperatore.Value : DBNull.Value;
        cmd.Parameters.Add("@CodOperatore", SqlDbType.VarChar, 20).Value = request.CodOperatore.Trim();
        cmd.Parameters.Add("@Nome", SqlDbType.VarChar, 100).Value = request.Nome.Trim();
        cmd.Parameters.Add("@Cognome", SqlDbType.VarChar, 100).Value = DbValue(request.Cognome, 100);
        cmd.Parameters.Add("@FonteEsterna", SqlDbType.VarChar, 50).Value = DbValue(request.FonteEsterna, 50);
        cmd.Parameters.Add("@CodiceEsterno", SqlDbType.VarChar, 50).Value = DbValue(request.CodiceEsterno, 50);
        AddDecimal(cmd, "@CostoOrarioRiferimento", request.CostoOrarioRiferimento, 18, 4);
        cmd.Parameters.Add("@Attivo", SqlDbType.Bit).Value = request.Attivo;
        cmd.Parameters.Add("@DataObsolescenza", SqlDbType.Date).Value = request.DataObsolescenza.HasValue ? request.DataObsolescenza.Value.Date : (!request.Attivo ? DateTime.Today : (object)DBNull.Value);
        cmd.Parameters.Add("@MotivoObsolescenza", SqlDbType.VarChar, 255).Value = DbValue(request.MotivoObsolescenza, 255);
        cmd.Parameters.Add("@Utente", SqlDbType.VarChar, 50).Value = "FactoryFlow";
    }

    private static OperatoreDto ReadOperatore(SqlDataReader reader) => new()
    {
        IdOperatore = Convert.ToInt32(reader["IdOperatore"]),
        CodOperatore = GetString(reader, "CodOperatore"),
        Nome = GetString(reader, "Nome"),
        Cognome = GetNullableString(reader, "Cognome"),
        FonteEsterna = GetNullableString(reader, "FonteEsterna"),
        CodiceEsterno = GetNullableString(reader, "CodiceEsterno"),
        CostoOrarioRiferimento = GetNullableDecimal(reader, "CostoOrarioRiferimento"),
        DataObsolescenza = reader["DataObsolescenza"] == DBNull.Value ? null : Convert.ToDateTime(reader["DataObsolescenza"]),
        MotivoObsolescenza = GetNullableString(reader, "MotivoObsolescenza"),
        Attivo = Convert.ToBoolean(reader["Attivo"])
    };

    private static RuoloOperativoDto ReadRuolo(SqlDataReader reader) => new()
    {
        IdRuoloOperativo = Convert.ToInt32(reader["IdRuoloOperativo"]),
        CodRuolo = GetString(reader, "CodRuolo"),
        Descrizione = GetString(reader, "Descrizione"),
        Attivo = Convert.ToBoolean(reader["Attivo"])
    };

    private static void AddDecimal(SqlCommand cmd, string name, decimal? value, byte precision, byte scale)
    {
        cmd.Parameters.Add(name, SqlDbType.Decimal).Value = value.HasValue ? value.Value : DBNull.Value;
        cmd.Parameters[name].Precision = precision;
        cmd.Parameters[name].Scale = scale;
    }

    private static object DbValue(string? value, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value)) return DBNull.Value;
        var trimmed = value.Trim();
        return trimmed.Length > maxLength ? trimmed[..maxLength] : trimmed;
    }

    private static string GetString(SqlDataReader reader, string field) => reader[field]?.ToString()?.Trim() ?? "";
    private static string? GetNullableString(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : GetString(reader, field);
    private static decimal? GetNullableDecimal(SqlDataReader reader, string field) => reader[field] == DBNull.Value ? null : Convert.ToDecimal(reader[field]);
}









