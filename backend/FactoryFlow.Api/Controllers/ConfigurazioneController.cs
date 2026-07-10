using FactoryFlow.Api.Services;
using FactoryFlow.Core.Models.Configurazione;
using Microsoft.AspNetCore.Mvc;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/configurazione")]
public sealed class ConfigurazioneController : ControllerBase
{
    private readonly ConfigurazioneService _service;

    public ConfigurazioneController(ConfigurazioneService service)
    {
        _service = service;
    }

    [HttpGet("attiva")]
    public async Task<ActionResult<ConfigurazioneAttivaDto>> GetAttiva(CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetAttivaAsync(ct));
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento configurazione attiva: {ex.Message}");
        }
    }
}
