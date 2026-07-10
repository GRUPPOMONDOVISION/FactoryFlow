using FactoryFlow.Api.Services;
using FactoryFlow.Core.Models.Operatori;
using Microsoft.AspNetCore.Mvc;

namespace FactoryFlow.Api.Controllers;

[ApiController]
public sealed class OperatoriController : ControllerBase
{
    private readonly OperatoriService _service;

    public OperatoriController(OperatoriService service)
    {
        _service = service;
    }

    [HttpGet("api/operatori")]
    public async Task<ActionResult<List<OperatoreDto>>> GetOperatori(CancellationToken ct)
    {
        return Ok(await _service.GetOperatoriAsync(ct));
    }

    [HttpPost("api/operatori")]
    public async Task<ActionResult<OperatoreDto>> CreateOperatore([FromBody] OperatoreRequestDto request, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.CreateOperatoreAsync(request, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("api/ruoli-operativi")]
    public async Task<ActionResult<List<RuoloOperativoDto>>> GetRuoli(CancellationToken ct)
    {
        return Ok(await _service.GetRuoliAsync(ct));
    }

    [HttpPost("api/ruoli-operativi")]
    public async Task<ActionResult<RuoloOperativoDto>> CreateRuolo([FromBody] RuoloOperativoRequestDto request, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.CreateRuoloAsync(request, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}
