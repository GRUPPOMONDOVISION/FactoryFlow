using FactoryFlow.Core.Models.Operatori;

namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneStoricoUpdateDto
{
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public DateTime DataProduzione { get; set; }
    public DateTime? OraInizioProduzione { get; set; }
    public DateTime? OraFineProduzione { get; set; }
    public string? DescrizionePF { get; set; }
    public string? LottoPF { get; set; }
    public string MagazzinoPF { get; set; } = "";
    public decimal QuantitaProdotta { get; set; }
    public List<DichiarazioneStoricoComponenteDto> Componenti { get; set; } = new();
    public List<DichiarazioneOperatoreDto> Operatori { get; set; } = new();
}




