namespace FactoryFlow.Core.Models.Produzione;

public sealed class ProduttivitaArticoloDto
{
    public string CodArticolo { get; set; } = "";
    public int? IdLinea { get; set; }
    public decimal? MediaQuantitaMinuto { get; set; }
    public int NumeroDichiarazioni { get; set; }
    public DateTime? UltimaRilevazione { get; set; }
}
