using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Linee;
using FactoryFlow.Core.Models.Produzione;

namespace FactoryFlow.Api.Services;

public sealed class LineeService
{
    private readonly ILineeRepository _repository;

    public LineeService(ILineeRepository repository)
    {
        _repository = repository;
    }

    public Task<List<LineaDto>> GetLineeAsync(CancellationToken ct = default)
    {
        return _repository.GetLineeAsync(ct);
    }

    public Task<List<ArticoloProduzioneDto>> GetArticoliLineaAsync(int idLinea, CancellationToken ct = default)
    {
        if (idLinea <= 0)
            throw new InvalidOperationException("Linea non valida.");

        return _repository.GetArticoliLineaAsync(idLinea, ct);
    }

    public Task<LineaDto> CreateLineaAsync(LineaRequestDto request, CancellationToken ct = default)
    {
        ValidateLinea(request);
        return _repository.CreateLineaAsync(request, ct);
    }

    public async Task<LineaDto> UpdateLineaAsync(int id, LineaRequestDto request, CancellationToken ct = default)
    {
        if (id <= 0)
            throw new InvalidOperationException("Linea non valida.");

        ValidateLinea(request);
        return await _repository.UpdateLineaAsync(id, request, ct)
            ?? throw new InvalidOperationException("Linea non trovata.");
    }

    public Task AddArticoloLineaAsync(int idLinea, LineaArticoloRequestDto request, CancellationToken ct = default)
    {
        if (idLinea <= 0)
            throw new InvalidOperationException("Linea non valida.");

        if (string.IsNullOrWhiteSpace(request.CodArticolo))
            throw new InvalidOperationException("Codice articolo mancante.");

        return _repository.AddArticoloLineaAsync(idLinea, request, ct);
    }

    public Task RemoveArticoloLineaAsync(int idLinea, string codArticolo, CancellationToken ct = default)
    {
        if (idLinea <= 0)
            throw new InvalidOperationException("Linea non valida.");

        if (string.IsNullOrWhiteSpace(codArticolo))
            throw new InvalidOperationException("Codice articolo mancante.");

        return _repository.RemoveArticoloLineaAsync(idLinea, codArticolo, ct);
    }

    private static void ValidateLinea(LineaRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.CodLinea))
            throw new InvalidOperationException("Codice linea mancante.");

        if (string.IsNullOrWhiteSpace(request.NomeLinea))
            throw new InvalidOperationException("Nome linea mancante.");
    }
}

