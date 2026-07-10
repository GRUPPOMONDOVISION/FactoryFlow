using FactoryFlow.Api.Services;
using FactoryFlow.Core.Models.Linee;
using FactoryFlow.Core.Models.Produzione;
using Microsoft.AspNetCore.Mvc;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/linee")]
public sealed class LineeController : ControllerBase
{
    private readonly LineeService _service;

    public LineeController(LineeService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<List<LineaDto>>> GetLinee(CancellationToken ct)
    {
        return Ok(await _service.GetLineeAsync(ct));
    }

    [HttpPost]
    public async Task<ActionResult<LineaDto>> CreateLinea([FromBody] LineaRequestDto request, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.CreateLineaAsync(request, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<LineaDto>> UpdateLinea(int id, [FromBody] LineaRequestDto request, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.UpdateLineaAsync(id, request, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("{id:int}/articoli")]
    public async Task<ActionResult<List<ArticoloProduzioneDto>>> GetArticoliLinea(int id, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetArticoliLineaAsync(id, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpDelete("{id:int}/articoli/{*codArticolo}")]
    public async Task<ActionResult> RemoveArticoloLinea(int id, string codArticolo, CancellationToken ct)
    {
        try
        {
            await _service.RemoveArticoloLineaAsync(id, codArticolo, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
    [HttpPost("{id:int}/articoli")]
    public async Task<ActionResult> AddArticoloLinea(int id, [FromBody] LineaArticoloRequestDto request, CancellationToken ct)
    {
        try
        {
            await _service.AddArticoloLineaAsync(id, request, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }
}


