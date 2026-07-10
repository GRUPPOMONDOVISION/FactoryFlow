using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Configurazione;

namespace FactoryFlow.Api.Services;

public sealed class ConfigurazioneService
{
    private readonly IConfigurazioneRepository _repository;

    public ConfigurazioneService(IConfigurazioneRepository repository)
    {
        _repository = repository;
    }

    public async Task<ConfigurazioneAttivaDto> GetAttivaAsync(CancellationToken ct = default)
    {
        return await _repository.GetAttivaAsync(ct)
            ?? throw new InvalidOperationException("Configurazione FactoryFlow attiva mancante.");
    }
}
