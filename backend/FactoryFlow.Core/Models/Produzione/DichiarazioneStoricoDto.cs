using FactoryFlow.Core.Models.Operatori;

namespace FactoryFlow.Core.Models.Produzione;

public sealed class DichiarazioneStoricoDto
{
    public long IdDichiarazione { get; set; }
    public int? IdLinea { get; set; }
    public int? IdMacchina { get; set; }
    public string? CodLinea { get; set; }
    public string? NomeLinea { get; set; }
    public string? CodMacchina { get; set; }
    public string? NomeMacchina { get; set; }
    public string CodAziAdhoc { get; set; } = "";
    public DateTime DataProduzione { get; set; }
    public DateTime? OraInizioProduzione { get; set; }
    public DateTime? OraFineProduzione { get; set; }
    public string CodArticoloPF { get; set; } = "";
    public string? DescrizionePF { get; set; }
    public string? LottoPF { get; set; }
    public string MagazzinoPF { get; set; } = "";
    public decimal QuantitaProdotta { get; set; }
    public decimal? ProduttivitaMinuto { get; set; }
    public decimal? MediaProduttivitaMinuto { get; set; }
    public decimal? ScostamentoProduttivitaPercentuale { get; set; }
    public string? SerialeCaricoAdhoc { get; set; }
    public int? NumeroCaricoAdhoc { get; set; }
    public string? SerialeScaricoAdhoc { get; set; }
    public int? NumeroScaricoAdhoc { get; set; }
    public string Stato { get; set; } = "";
    public DateTime DataCreazione { get; set; }
    public DateTime? DataModifica { get; set; }
    public List<DichiarazioneStoricoComponenteDto> Componenti { get; set; } = new();
    public List<DichiarazioneOperatoreDto> Operatori { get; set; } = new();
}







