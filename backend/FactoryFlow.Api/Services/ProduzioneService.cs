using FactoryFlow.Core.Interfaces;
using FactoryFlow.Core.Models.Produzione;

namespace FactoryFlow.Api.Services;

public sealed class ProduzioneService
{
    private readonly IProduzioneRepository _repository;

    public ProduzioneService(IProduzioneRepository repository)
    {
        _repository = repository;
    }

    public Task<List<ArticoloProduzioneDto>> GetArticoliAsync(CancellationToken ct = default)
    {
        return _repository.GetArticoliAsync(ct);
    }

    public Task<ProduttivitaArticoloDto> GetProduttivitaArticoloAsync(
        string codArticolo,
        int? idLinea,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(codArticolo))
            throw new InvalidOperationException("Codice articolo mancante.");

        return _repository.GetProduttivitaArticoloAsync(codArticolo, idLinea, ct);
    }
    public async Task<DistintaProduzioneDto?> GetDistintaAsync(
        string codArticolo,
        decimal quantita,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(codArticolo))
            throw new InvalidOperationException("Codice articolo mancante.");

        if (quantita <= 0)
            throw new InvalidOperationException("Quantita prodotta non valida.");

        return await _repository.GetDistintaAsync(codArticolo, quantita, ct);
    }

    public async Task<List<LottoProduzioneDto>> GetLottiAsync(
        string codArticolo,
        string magazzino,
        DateTime dataProduzione,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(codArticolo))
            throw new InvalidOperationException("Codice articolo mancante.");

        if (string.IsNullOrWhiteSpace(magazzino))
            throw new InvalidOperationException("Magazzino mancante.");

        if (dataProduzione == default)
            throw new InvalidOperationException("Data produzione mancante.");

        return await _repository.GetLottiAsync(codArticolo, magazzino, dataProduzione, ct);
    }

    public Task<List<DichiarazioneCalendarioGiornoDto>> GetCalendarioDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default)
    {
        ValidatePeriodo(dal, al);
        return _repository.GetCalendarioDichiarazioniAsync(dal, al, ct);
    }

    public Task<List<DichiarazioneStoricoDto>> GetDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default)
    {
        ValidatePeriodo(dal, al);
        return _repository.GetDichiarazioniAsync(dal, al, ct);
    }

    public async Task<DichiarazioneStoricoDto> GetDichiarazioneAsync(
        long idDichiarazione,
        CancellationToken ct = default)
    {
        if (idDichiarazione <= 0)
            throw new InvalidOperationException("Dichiarazione non valida.");

        return await _repository.GetDichiarazioneAsync(idDichiarazione, ct)
            ?? throw new InvalidOperationException("Dichiarazione non trovata.");
    }

    public Task UpdateDichiarazioneStoricoAsync(
        long idDichiarazione,
        DichiarazioneStoricoUpdateDto request,
        CancellationToken ct = default)
    {
        if (idDichiarazione <= 0)
            throw new InvalidOperationException("Dichiarazione non valida.");

        if (request.DataProduzione == default)
            throw new InvalidOperationException("Data produzione mancante.");

        if (request.QuantitaProdotta <= 0)
            throw new InvalidOperationException("Quantita prodotta non valida.");

        ValidateEventoProduttivo(request.DataProduzione, request.OraInizioProduzione, request.OraFineProduzione);

        if (string.IsNullOrWhiteSpace(request.MagazzinoPF))
            throw new InvalidOperationException("Magazzino prodotto finito mancante.");

        foreach (var componente in request.Componenti)
        {
            if (string.IsNullOrWhiteSpace(componente.CodComponente))
                throw new InvalidOperationException("Codice componente mancante.");

            if (componente.QuantitaEffettiva < 0)
                throw new InvalidOperationException($"Quantita componente non valida per {componente.CodComponente}.");

            if (string.IsNullOrWhiteSpace(componente.Magazzino))
                throw new InvalidOperationException($"Magazzino componente mancante per {componente.CodComponente}.");
        }

        return _repository.UpdateDichiarazioneStoricoAsync(idDichiarazione, request, ct);
    }

    public Task AnnullaDichiarazioneStoricoAsync(long idDichiarazione, CancellationToken ct = default)
    {
        if (idDichiarazione <= 0)
            throw new InvalidOperationException("Dichiarazione non valida.");

        return _repository.AnnullaDichiarazioneStoricoAsync(idDichiarazione, ct);
    }

    public Task<DichiarazioneProduzioneResultDto> ConfermaDichiarazionePrevistaAsync(long idDichiarazione, CancellationToken ct = default)
    {
        if (idDichiarazione <= 0)
            throw new InvalidOperationException("Dichiarazione non valida.");

        return _repository.ConfermaDichiarazionePrevistaAsync(idDichiarazione, ct);
    }
    public async Task<DichiarazioneProduzioneResultDto> CreaDichiarazioneAsync(
        DichiarazioneProduzioneRequestDto request,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.ArticoloProdotto))
            throw new InvalidOperationException("Articolo prodotto mancante.");

        if (request.QuantitaProdotta <= 0)
            throw new InvalidOperationException("Quantita prodotta non valida.");

        if (request.DataProduzione == default)
            throw new InvalidOperationException("Data produzione mancante.");

        ValidateEventoProduttivo(request.DataProduzione, request.OraInizioProduzione, request.OraFineProduzione);

        if (string.IsNullOrWhiteSpace(request.LottoProdotto))
            throw new InvalidOperationException("Lotto prodotto finito mancante.");

        if (request.Componenti.Count == 0)
            throw new InvalidOperationException("Componenti mancanti.");

        foreach (var componente in request.Componenti)
        {
            if (string.IsNullOrWhiteSpace(componente.Codice))
                throw new InvalidOperationException("Codice componente mancante.");

            if (componente.Quantita <= 0)
                throw new InvalidOperationException($"Quantita componente non valida per {componente.Codice}.");
        }

        return await _repository.CreaDichiarazioneAsync(request, ct);
    }

    private static void ValidateEventoProduttivo(DateTime dataProduzione, DateTime? oraInizio, DateTime? oraFine)
    {
        if (!oraInizio.HasValue)
            throw new InvalidOperationException("Ora inizio produzione mancante.");

        if (!oraFine.HasValue)
            throw new InvalidOperationException("Ora fine produzione mancante.");

        if (oraInizio.Value.Date != dataProduzione.Date || oraFine.Value.Date != dataProduzione.Date)
            throw new InvalidOperationException("Ora inizio e ora fine devono appartenere alla data produzione.");

        if (oraFine.Value <= oraInizio.Value)
            throw new InvalidOperationException("Ora fine produzione deve essere successiva all'ora inizio.");
    }

    private static void ValidatePeriodo(DateTime dal, DateTime al)
    {
        if (dal == default || al == default)
            throw new InvalidOperationException("Periodo non valido.");

        if (al.Date < dal.Date)
            throw new InvalidOperationException("Periodo non valido.");
    }
}





