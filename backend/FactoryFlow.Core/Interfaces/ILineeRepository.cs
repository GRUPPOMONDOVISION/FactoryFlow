using FactoryFlow.Core.Models.Linee;
using FactoryFlow.Core.Models.Produzione;

namespace FactoryFlow.Core.Interfaces;

public interface ILineeRepository
{
    Task<List<LineaDto>> GetLineeAsync(CancellationToken ct = default);
    Task<LineaDto> CreateLineaAsync(LineaRequestDto request, CancellationToken ct = default);
    Task<LineaDto?> UpdateLineaAsync(int id, LineaRequestDto request, CancellationToken ct = default);
    Task<List<ArticoloProduzioneDto>> GetArticoliLineaAsync(int idLinea, CancellationToken ct = default);
    Task AddArticoloLineaAsync(int idLinea, LineaArticoloRequestDto request, CancellationToken ct = default);
    Task RemoveArticoloLineaAsync(int idLinea, string codArticolo, CancellationToken ct = default);
}

