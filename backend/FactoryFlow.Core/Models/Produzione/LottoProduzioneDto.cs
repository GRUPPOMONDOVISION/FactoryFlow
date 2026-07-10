namespace FactoryFlow.Core.Models.Produzione;

public sealed class LottoProduzioneDto
{
    public string CodiceLotto { get; set; } = "";
    public decimal Disponibilita { get; set; }
    public DateTime? DataScadenza { get; set; }
    public string Magazzino { get; set; } = "";
}
