namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneStoricoComponenteDto
{
    public long IdRiga { get; set; }
    public string CodComponente { get; set; } = "";
    public string? DescrizioneComponente { get; set; }
    public string? UnitaMisura { get; set; }
    public decimal? QuantitaDistinta { get; set; }
    public decimal? QuantitaProposta { get; set; }
    public decimal QuantitaEffettiva { get; set; }
    public string? Lotto { get; set; }
    public string Magazzino { get; set; } = "";
    public bool GestioneLotti { get; set; }
}


