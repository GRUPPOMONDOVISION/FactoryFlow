namespace FactoryFlow.Core.Models.Operatori;

public sealed class OperatoreRequestDto
{
    public int? IdOperatore { get; set; }
    public string CodOperatore { get; set; } = "";
    public string Nome { get; set; } = "";
    public string? Cognome { get; set; }
    public string? FonteEsterna { get; set; }
    public string? CodiceEsterno { get; set; }
    public decimal? CostoOrarioRiferimento { get; set; }
    public bool Attivo { get; set; } = true;
    public DateTime? DataObsolescenza { get; set; }
    public string? MotivoObsolescenza { get; set; }
}
