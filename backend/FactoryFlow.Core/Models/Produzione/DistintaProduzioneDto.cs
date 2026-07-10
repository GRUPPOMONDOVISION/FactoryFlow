namespace FactoryFlow.Core.Models.Produzione;

public sealed class DistintaProduzioneDto
{
    public string CodArticolo { get; set; } = "";
    public decimal QuantitaProdotta { get; set; }
    public List<ComponenteDistintaDto> Componenti { get; set; } = new();
}
