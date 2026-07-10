namespace FactoryFlow.Core.Models.Operatori;

public sealed class DichiarazioneOperatoreDto
{
    public long? IdDichiarazioneOperatore { get; set; }
    public int? IdOperatore { get; set; }
    public int? IdRuoloOperativo { get; set; }
    public string? CodOperatoreSnapshot { get; set; }
    public string? NomeOperatoreSnapshot { get; set; }
    public string? RuoloSnapshot { get; set; }
    public DateTime? OraInizio { get; set; }
    public DateTime? OraFine { get; set; }
    public string? Note { get; set; }
}
