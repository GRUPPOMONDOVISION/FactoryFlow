namespace FactoryFlow.Core.Models.Linee;

public sealed class LineaRequestDto
{
    public string CodLinea { get; set; } = "";
    public string NomeLinea { get; set; } = "";
    public string? DescrizioneFunzionale { get; set; }
    public bool Attiva { get; set; } = true;
}
