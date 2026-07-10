namespace FactoryFlow.Core.Models.Linee;

public sealed class LineaDto
{
    public int IdLinea { get; set; }
    public string CodLinea { get; set; } = "";
    public string NomeLinea { get; set; } = "";
    public string? DescrizioneFunzionale { get; set; }
    public bool Attiva { get; set; }
}
