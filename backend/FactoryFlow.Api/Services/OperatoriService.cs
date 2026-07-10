using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Operatori;

namespace FactoryFlow.Api.Services;

public sealed class OperatoriService
{
    private readonly IOperatoriRepository _repository;

    public OperatoriService(IOperatoriRepository repository)
    {
        _repository = repository;
    }

    public Task<List<OperatoreDto>> GetOperatoriAsync(CancellationToken ct = default) => _repository.GetOperatoriAsync(ct);

    public Task<OperatoreDto> CreateOperatoreAsync(OperatoreRequestDto request, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.CodOperatore))
            throw new InvalidOperationException("Codice operatore mancante.");
        if (string.IsNullOrWhiteSpace(request.Nome))
            throw new InvalidOperationException("Nome operatore mancante.");
        return _repository.CreateOperatoreAsync(request, ct);
    }

    public Task<List<RuoloOperativoDto>> GetRuoliAsync(CancellationToken ct = default) => _repository.GetRuoliAsync(ct);

    public Task<RuoloOperativoDto> CreateRuoloAsync(RuoloOperativoRequestDto request, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.CodRuolo))
            throw new InvalidOperationException("Codice ruolo mancante.");
        if (string.IsNullOrWhiteSpace(request.Descrizione))
            throw new InvalidOperationException("Descrizione ruolo mancante.");
        return _repository.CreateRuoloAsync(request, ct);
    }
}
