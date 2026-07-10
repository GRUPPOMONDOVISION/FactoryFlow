using FactoryFlow.Core.Models.Configurazione;

namespace FactoryFlow.Core.Interfaces;

public interface IConfigurazioneRepository
{
    Task<ConfigurazioneAttivaDto?> GetAttivaAsync(CancellationToken ct = default);
}
