using FactoryFlow.Core.Models.Operatori;

namespace FactoryFlow.Core.Interfaces;

public interface IOperatoriRepository
{
    Task<List<OperatoreDto>> GetOperatoriAsync(CancellationToken ct = default);
    Task<OperatoreDto> CreateOperatoreAsync(OperatoreRequestDto request, CancellationToken ct = default);
    Task<List<RuoloOperativoDto>> GetRuoliAsync(CancellationToken ct = default);
    Task<RuoloOperativoDto> CreateRuoloAsync(RuoloOperativoRequestDto request, CancellationToken ct = default);
}
