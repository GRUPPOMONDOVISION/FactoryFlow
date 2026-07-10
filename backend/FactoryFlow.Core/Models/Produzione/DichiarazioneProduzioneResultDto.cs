namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneProduzioneResultDto
{
    public bool Ok { get; set; }
    public string Messaggio { get; set; } = "";
    public string? SerialCarico { get; set; }
    public int? NumeroCarico { get; set; }
    public string? SerialScarico { get; set; }
    public int? NumeroScarico { get; set; }
}
