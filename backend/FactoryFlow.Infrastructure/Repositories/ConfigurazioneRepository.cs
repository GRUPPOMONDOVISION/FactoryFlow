using System.Data;
using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Configurazione;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace FactoryFlow.Infrastructure.Repositories;

public sealed class ConfigurazioneRepository : IConfigurazioneRepository
{
    private readonly string _farmFlowConnectionString;

    public ConfigurazioneRepository(IConfiguration configuration)
    {
        _farmFlowConnectionString = configuration.GetConnectionString("FarmFlowConnection")
            ?? throw new InvalidOperationException("Connection string FarmFlowConnection mancante.");
    }

    public async Task<ConfigurazioneAttivaDto?> GetAttivaAsync(CancellationToken ct = default)
    {
        await using var conn = new SqlConnection(_farmFlowConnectionString);
        await using var cmd = new SqlCommand("dbo.sp_FF_Config_GetAttiva", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        await conn.OpenAsync(ct);
        await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow, ct);

        if (!await reader.ReadAsync(ct))
            return null;

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

    private static string GetString(SqlDataReader reader, string field)
    {
        return reader[field]?.ToString()?.Trim() ?? "";
    }
}
