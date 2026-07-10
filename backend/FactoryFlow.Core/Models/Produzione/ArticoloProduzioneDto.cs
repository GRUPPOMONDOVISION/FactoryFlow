namespace FactoryFlow.Core.Models.Produzione;

public sealed class ArticoloProduzioneDto
{
    public string CodArticolo { get; set; } = "";
    public string Descrizione { get; set; } = "";
    public string UnitaMisura { get; set; } = "";
    public string CodiceDistinta { get; set; } = "";
    public bool GestioneLotti { get; set; }
}
