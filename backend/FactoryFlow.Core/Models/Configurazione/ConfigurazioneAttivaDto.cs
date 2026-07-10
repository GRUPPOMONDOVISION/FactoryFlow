namespace FactoryFlow.Core.Models.Configurazione;

public sealed class ConfigurazioneAttivaDto
{
    public int IdConfig { get; set; }
    public string CodAziAdhoc { get; set; } = "";
    public string PrefissoAzienda { get; set; } = "";
    public string CausaleCarico { get; set; } = "";
    public string CausaleScarico { get; set; } = "";
    public string MagazzinoPFDefault { get; set; } = "";
    public string MagazzinoComponentiDefault { get; set; } = "";
}
