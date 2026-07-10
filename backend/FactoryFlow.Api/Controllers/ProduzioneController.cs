using FactoryFlow.Api.Services;
using FactoryFlow.Core.Models.Produzione;
using Microsoft.AspNetCore.Mvc;

namespace FactoryFlow.Api.Controllers;

[ApiController]
[Route("api/produzione")]
public sealed class ProduzioneController : ControllerBase
{
    private readonly ProduzioneService _service;

    public ProduzioneController(ProduzioneService service)
    {
        _service = service;
    }

    [HttpGet("articoli")]
    public async Task<ActionResult<List<ArticoloProduzioneDto>>> GetArticoli(CancellationToken ct)
    {
        try
        {
            var result = await _service.GetArticoliAsync(ct);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento articoli producibili: {ex.Message}");
        }
    }

    [HttpGet("articoli/{codArticolo}/produttivita")]
    public async Task<ActionResult<ProduttivitaArticoloDto>> GetProduttivitaArticolo(
        string codArticolo,
        int? idLinea,
        CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetProduttivitaArticoloAsync(codArticolo, idLinea, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore calcolo produttivita articolo: {ex.Message}");
        }
    }
    [HttpGet("distinta")]
    public async Task<ActionResult<DistintaProduzioneDto>> GetDistinta(
        string codArticolo,
        decimal quantita,
        CancellationToken ct)
    {
        try
        {
            var result = await _service.GetDistintaAsync(codArticolo, quantita, ct);

            if (result == null)
                return NotFound("Distinta non trovata.");

            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento distinta: {ex.Message}");
        }
    }

    [HttpGet("lotti")]
    public async Task<ActionResult<List<LottoProduzioneDto>>> GetLotti(
        string codArticolo,
        string magazzino,
        DateTime dataProduzione,
        CancellationToken ct)
    {
        try
        {
            var result = await _service.GetLottiAsync(codArticolo, magazzino, dataProduzione, ct);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento lotti: {ex.Message}");
        }
    }

    [HttpGet("dichiarazioni/calendario")]
    public async Task<ActionResult<List<DichiarazioneCalendarioGiornoDto>>> GetCalendarioDichiarazioni(
        DateTime dal,
        DateTime al,
        CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetCalendarioDichiarazioniAsync(dal, al, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento calendario dichiarazioni: {ex.Message}");
        }
    }

    [HttpGet("dichiarazioni")]
    public async Task<ActionResult<List<DichiarazioneStoricoDto>>> GetDichiarazioni(
        DateTime dal,
        DateTime al,
        CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetDichiarazioniAsync(dal, al, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento dichiarazioni: {ex.Message}");
        }
    }

    [HttpGet("dichiarazioni/{id:long}")]
    public async Task<ActionResult<DichiarazioneStoricoDto>> GetDichiarazione(long id, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.GetDichiarazioneAsync(id, ct));
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore caricamento dichiarazione: {ex.Message}");
        }
    }

    [HttpPut("dichiarazioni/{id:long}")]
    public async Task<ActionResult> UpdateDichiarazioneStorico(
        long id,
        [FromBody] DichiarazioneStoricoUpdateDto request,
        CancellationToken ct)
    {
        try
        {
            await _service.UpdateDichiarazioneStoricoAsync(id, request, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore salvataggio storico dichiarazione: {ex.Message}");
        }
    }

    [HttpDelete("dichiarazioni/{id:long}")]
    public async Task<ActionResult> AnnullaDichiarazioneStorico(long id, CancellationToken ct)
    {
        try
        {
            await _service.AnnullaDichiarazioneStoricoAsync(id, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore annullamento storico dichiarazione: {ex.Message}");
        }
    }
    [HttpPost("dichiarazioni/{id:long}/conferma")]
    public async Task<ActionResult<DichiarazioneProduzioneResultDto>> ConfermaDichiarazionePrevista(long id, CancellationToken ct)
    {
        try
        {
            return Ok(await _service.ConfermaDichiarazionePrevistaAsync(id, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore conferma dichiarazione prevista: {ex.Message}");
        }
    }
    [HttpPost("dichiarazione")]
    public async Task<ActionResult<DichiarazioneProduzioneResultDto>> CreaDichiarazione(
        [FromBody] DichiarazioneProduzioneRequestDto request,
        CancellationToken ct)
    {
        try
        {
            var result = await _service.CreaDichiarazioneAsync(request, ct);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Errore conferma produzione: {ex.Message}");
        }
    }
}



