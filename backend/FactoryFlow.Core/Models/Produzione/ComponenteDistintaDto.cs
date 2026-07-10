namespace FactoryFlow.Core.Models.Produzione;

public sealed class ComponenteDistintaDto
{
    public string CodComponente { get; set; } = "";
    public string Descrizione { get; set; } = "";
    public string UnitaMisura { get; set; } = "";
    public decimal QuantitaDistinta { get; set; }
    public decimal QuantitaProposta { get; set; }
    public decimal QuantitaDaScaricare { get; set; }
    public string Magazzino { get; set; } = "01";
    public bool GestioneLotti { get; set; }
}
