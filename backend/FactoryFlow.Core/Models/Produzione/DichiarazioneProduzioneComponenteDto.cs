namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneProduzioneComponenteDto
{
    public string Codice { get; set; } = "";
    public string? Descrizione { get; set; }
    public string? UnitaMisura { get; set; }
    public decimal? QuantitaDistinta { get; set; }
    public decimal? QuantitaProposta { get; set; }
    public string? Lotto { get; set; }
    public string Magazzino { get; set; } = "";
    public decimal Quantita { get; set; }
}
