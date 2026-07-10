using FactoryFlow.Core.Models.Operatori;

namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneProduzioneRequestDto
{
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public string CodAzi { get; set; } = "";
    public int Esercizio { get; set; }
    public DateTime DataProduzione { get; set; }
    public DateTime? OraInizioProduzione { get; set; }
    public DateTime? OraFineProduzione { get; set; }
    public string ArticoloProdotto { get; set; } = "";
    public string? DescrizioneProdotto { get; set; }
    public string LottoProdotto { get; set; } = "";
    public string MagazzinoProdotto { get; set; } = "";
    public decimal QuantitaProdotta { get; set; }
    public List<DichiarazioneProduzioneComponenteDto> Componenti { get; set; } = new();
    public List<DichiarazioneOperatoreDto> Operatori { get; set; } = new();
}




