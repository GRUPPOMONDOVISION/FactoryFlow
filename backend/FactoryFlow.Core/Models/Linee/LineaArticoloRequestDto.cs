namespace FactoryFlow.Core.Models.Linee;

public sealed class LineaArticoloRequestDto
{
    public string CodArticolo { get; set; } = "";
    public decimal? QuantitaMinuto { get; set; }
    public bool Attivo { get; set; } = true;
}
