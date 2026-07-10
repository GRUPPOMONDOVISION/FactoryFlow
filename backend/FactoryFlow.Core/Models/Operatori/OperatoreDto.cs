namespace FactoryFlow.Core.Models.Operatori;

public sealed class OperatoreDto
{
    public int IdOperatore { get; set; }
    public string CodOperatore { get; set; } = "";
    public string Nome { get; set; } = "";
    public string? Cognome { get; set; }
    public string? FonteEsterna { get; set; }
    public string? CodiceEsterno { get; set; }
    public decimal? CostoOrarioRiferimento { get; set; }
    public DateTime? DataObsolescenza { get; set; }
    public string? MotivoObsolescenza { get; set; }
    public bool Attivo { get; set; }
}
