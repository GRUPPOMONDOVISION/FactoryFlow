using FactoryFlow.Core.Models.Produzione;

namespace FactoryFlow.Core.Interfaces;

public interface IProduzioneRepository
{
    Task<List<ArticoloProduzioneDto>> GetArticoliAsync(CancellationToken ct = default);

    Task<DistintaProduzioneDto?> GetDistintaAsync(
        string codArticolo,
        decimal quantita,
        CancellationToken ct = default);

    Task<ProduttivitaArticoloDto> GetProduttivitaArticoloAsync(
        string codArticolo,
        int? idLinea,
        CancellationToken ct = default);

    Task<List<LottoProduzioneDto>> GetLottiAsync(
        string codArticolo,
        string magazzino,
        DateTime dataProduzione,
        CancellationToken ct = default);

    Task<List<DichiarazioneCalendarioGiornoDto>> GetCalendarioDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default);

    Task<List<DichiarazioneStoricoDto>> GetDichiarazioniAsync(
        DateTime dal,
        DateTime al,
        CancellationToken ct = default);

    Task<DichiarazioneStoricoDto?> GetDichiarazioneAsync(
        long idDichiarazione,
        CancellationToken ct = default);

    Task UpdateDichiarazioneStoricoAsync(
        long idDichiarazione,
        DichiarazioneStoricoUpdateDto request,
        CancellationToken ct = default);

    Task AnnullaDichiarazioneStoricoAsync(
        long idDichiarazione,
        CancellationToken ct = default);

    Task<DichiarazioneProduzioneResultDto> ConfermaDichiarazionePrevistaAsync(
        long idDichiarazione,
        CancellationToken ct = default);

    Task<DichiarazioneProduzioneResultDto> CreaDichiarazioneAsync(
        DichiarazioneProduzioneRequestDto request,
        CancellationToken ct = default);
}

