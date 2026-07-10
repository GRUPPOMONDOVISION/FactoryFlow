namespace FactoryFlow.Core.Models.Operatori;

public sealed class RuoloOperativoRequestDto
{
    public int? IdRuoloOperativo { get; set; }
    public string CodRuolo { get; set; } = "";
    public string Descrizione { get; set; } = "";
    public bool Attivo { get; set; } = true;
}

