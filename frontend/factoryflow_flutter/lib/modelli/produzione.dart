class ArticoloProduzione {
  final String codArticolo;
  final String descrizione;
  final String unitaMisura;
  final String codiceDistinta;
  final bool gestioneLotti;

  const ArticoloProduzione({
    required this.codArticolo,
    required this.descrizione,
    required this.unitaMisura,
    required this.codiceDistinta,
    required this.gestioneLotti,
  });

  factory ArticoloProduzione.fromJson(Map<String, dynamic> json) {
    return ArticoloProduzione(
      codArticolo: json['codArticolo']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      unitaMisura: json['unitaMisura']?.toString() ?? '',
      codiceDistinta: json['codiceDistinta']?.toString() ?? '',
      gestioneLotti: json['gestioneLotti'] == true,
    );
  }

  String get label => '$codArticolo - $descrizione';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ArticoloProduzione && other.codArticolo == codArticolo;
  }

  @override
  int get hashCode => codArticolo.hashCode;
}

class ProduttivitaArticolo {
  final String codArticolo;
  final int? idLinea;
  final double? mediaQuantitaMinuto;
  final int numeroDichiarazioni;
  final DateTime? ultimaRilevazione;

  const ProduttivitaArticolo({
    required this.codArticolo,
    required this.idLinea,
    required this.mediaQuantitaMinuto,
    required this.numeroDichiarazioni,
    required this.ultimaRilevazione,
  });

  factory ProduttivitaArticolo.fromJson(Map<String, dynamic> json) {
    return ProduttivitaArticolo(
      codArticolo: json['codArticolo']?.toString() ?? '',
      idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
      mediaQuantitaMinuto: json['mediaQuantitaMinuto'] == null ? null : _toDouble(json['mediaQuantitaMinuto']),
      numeroDichiarazioni: int.tryParse(json['numeroDichiarazioni']?.toString() ?? '') ?? 0,
      ultimaRilevazione: json['ultimaRilevazione'] == null ? null : DateTime.tryParse(json['ultimaRilevazione'].toString()),
    );
  }
}
class LineaProduzione {
  final int idLinea;
  final String codLinea;
  final String nomeLinea;
  final String? descrizioneFunzionale;
  final bool attiva;

  const LineaProduzione({
    required this.idLinea,
    required this.codLinea,
    required this.nomeLinea,
    required this.descrizioneFunzionale,
    required this.attiva,
  });

  factory LineaProduzione.fromJson(Map<String, dynamic> json) {
    return LineaProduzione(
      idLinea: int.tryParse(json['idLinea']?.toString() ?? '') ?? 0,
      codLinea: json['codLinea']?.toString() ?? '',
      nomeLinea: json['nomeLinea']?.toString() ?? '',
      descrizioneFunzionale: json['descrizioneFunzionale']?.toString(),
      attiva: json['attiva'] != false,
    );
  }

  String get label => '$codLinea - $nomeLinea';
}

class DistintaProduzione {
  final String codArticolo;
  final double quantitaProdotta;
  final List<ComponenteDistinta> componenti;

  const DistintaProduzione({
    required this.codArticolo,
    required this.quantitaProdotta,
    required this.componenti,
  });

  factory DistintaProduzione.fromJson(Map<String, dynamic> json) {
    final rows = (json['componenti'] as List<dynamic>? ?? [])
        .map((e) => ComponenteDistinta.fromJson(e as Map<String, dynamic>))
        .toList();

    return DistintaProduzione(
      codArticolo: json['codArticolo']?.toString() ?? '',
      quantitaProdotta: _toDouble(json['quantitaProdotta']),
      componenti: rows,
    );
  }
}

class ComponenteDistinta {
  final String codComponente;
  final String descrizione;
  final String unitaMisura;
  final double quantitaDistinta;
  final double quantitaProposta;
  final String magazzino;
  final bool gestioneLotti;
  double quantitaDaScaricare;
  String? lotto;
  List<LottoProduzione> lotti;

  ComponenteDistinta({
    required this.codComponente,
    required this.descrizione,
    required this.unitaMisura,
    required this.quantitaDistinta,
    required this.quantitaProposta,
    required this.quantitaDaScaricare,
    required this.magazzino,
    required this.gestioneLotti,
    this.lotto,
    this.lotti = const [],
  });

  factory ComponenteDistinta.fromJson(Map<String, dynamic> json) {
    return ComponenteDistinta(
      codComponente: json['codComponente']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      unitaMisura: json['unitaMisura']?.toString() ?? '',
      quantitaDistinta: _toDouble(json['quantitaDistinta']),
      quantitaProposta: _toDouble(json['quantitaProposta']),
      quantitaDaScaricare: _toDouble(json['quantitaDaScaricare']),
      magazzino: json['magazzino']?.toString() ?? '01',
      gestioneLotti: json['gestioneLotti'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codice': codComponente,
      'descrizione': descrizione,
      'unitaMisura': unitaMisura,
      'quantitaDistinta': quantitaDistinta,
      'quantitaProposta': quantitaProposta,
      'lotto': lotto,
      'magazzino': magazzino,
      'gestioneLotti': gestioneLotti,
      'quantita': quantitaDaScaricare,
    };
  }
}

class LottoProduzione {
  final String codiceLotto;
  final double disponibilita;
  final DateTime? dataScadenza;
  final String magazzino;

  const LottoProduzione({
    required this.codiceLotto,
    required this.disponibilita,
    required this.dataScadenza,
    required this.magazzino,
  });

  factory LottoProduzione.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dataScadenza']?.toString();

    return LottoProduzione(
      codiceLotto: json['codiceLotto']?.toString() ?? '',
      disponibilita: _toDouble(json['disponibilita']),
      dataScadenza: rawDate == null || rawDate.isEmpty
          ? null
          : DateTime.tryParse(rawDate),
      magazzino: json['magazzino']?.toString() ?? '',
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 's' || text == 'yes';
}


class DichiarazioneCalendarioGiorno {
  final DateTime dataProduzione;
  final int numeroDichiarazioni;

  const DichiarazioneCalendarioGiorno({required this.dataProduzione, required this.numeroDichiarazioni});

  factory DichiarazioneCalendarioGiorno.fromJson(Map<String, dynamic> json) {
    return DichiarazioneCalendarioGiorno(
      dataProduzione: DateTime.parse(json['dataProduzione'].toString()),
      numeroDichiarazioni: int.tryParse(json['numeroDichiarazioni']?.toString() ?? '') ?? 0,
    );
  }
}

class DichiarazioneStorico {
  final int idDichiarazione;
  int? idLinea;
  int? idMacchina;
  final String? codLinea;
  final String? nomeLinea;
  final String? codMacchina;
  final String? nomeMacchina;
  final String codAziAdhoc;
  DateTime dataProduzione;
  DateTime? oraInizioProduzione;
  DateTime? oraFineProduzione;
  final String codArticoloPF;
  String? descrizionePF;
  String? lottoPF;
  String magazzinoPF;
  double quantitaProdotta;
  final double? produttivitaMinuto;
  final double? mediaProduttivitaMinuto;
  final double? scostamentoProduttivitaPercentuale;
  final String? serialeCaricoAdhoc;
  final int? numeroCaricoAdhoc;
  final String? serialeScaricoAdhoc;
  final int? numeroScaricoAdhoc;
  final String stato;
  final DateTime dataCreazione;
  final DateTime? dataModifica;
  List<DichiarazioneStoricoComponente> componenti;
  List<DichiarazioneOperatore> operatori;

  DichiarazioneStorico({
    required this.idDichiarazione,
    required this.idLinea,
    required this.codLinea,
    required this.nomeLinea,
    required this.idMacchina,
    required this.codMacchina,
    required this.nomeMacchina,
    required this.codAziAdhoc,
    required this.dataProduzione,
    required this.oraInizioProduzione,
    required this.oraFineProduzione,
    required this.codArticoloPF,
    required this.descrizionePF,
    required this.lottoPF,
    required this.magazzinoPF,
    required this.quantitaProdotta,
    required this.produttivitaMinuto,
    required this.mediaProduttivitaMinuto,
    required this.scostamentoProduttivitaPercentuale,
    required this.serialeCaricoAdhoc,
    required this.numeroCaricoAdhoc,
    required this.serialeScaricoAdhoc,
    required this.numeroScaricoAdhoc,
    required this.stato,
    required this.dataCreazione,
    required this.dataModifica,
    required this.componenti,
    required this.operatori,
  });

  factory DichiarazioneStorico.fromJson(Map<String, dynamic> json) {
    return DichiarazioneStorico(
      idDichiarazione: int.tryParse(json['idDichiarazione']?.toString() ?? '') ?? 0,
      idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
      codLinea: json['codLinea']?.toString(),
      nomeLinea: json['nomeLinea']?.toString(),
      idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
      codMacchina: json['codMacchina']?.toString(),
      nomeMacchina: json['nomeMacchina']?.toString(),
      codAziAdhoc: json['codAziAdhoc']?.toString() ?? '',
      dataProduzione: DateTime.parse(json['dataProduzione'].toString()),
      oraInizioProduzione: json['oraInizioProduzione'] == null ? null : DateTime.tryParse(json['oraInizioProduzione'].toString()),
      oraFineProduzione: json['oraFineProduzione'] == null ? null : DateTime.tryParse(json['oraFineProduzione'].toString()),
      codArticoloPF: json['codArticoloPF']?.toString() ?? '',
      descrizionePF: json['descrizionePF']?.toString(),
      lottoPF: json['lottoPF']?.toString(),
      magazzinoPF: json['magazzinoPF']?.toString() ?? '',
      quantitaProdotta: _toDouble(json['quantitaProdotta']),
      produttivitaMinuto: json['produttivitaMinuto'] == null ? null : _toDouble(json['produttivitaMinuto']),
      mediaProduttivitaMinuto: json['mediaProduttivitaMinuto'] == null ? null : _toDouble(json['mediaProduttivitaMinuto']),
      scostamentoProduttivitaPercentuale: json['scostamentoProduttivitaPercentuale'] == null ? null : _toDouble(json['scostamentoProduttivitaPercentuale']),
      serialeCaricoAdhoc: json['serialeCaricoAdhoc']?.toString(),
      numeroCaricoAdhoc: json['numeroCaricoAdhoc'] == null ? null : int.tryParse(json['numeroCaricoAdhoc'].toString()),
      serialeScaricoAdhoc: json['serialeScaricoAdhoc']?.toString(),
      numeroScaricoAdhoc: json['numeroScaricoAdhoc'] == null ? null : int.tryParse(json['numeroScaricoAdhoc'].toString()),
      stato: json['stato']?.toString() ?? '',
      dataCreazione: DateTime.parse(json['dataCreazione'].toString()),
      dataModifica: json['dataModifica'] == null ? null : DateTime.tryParse(json['dataModifica'].toString()),
      componenti: (json['componenti'] as List<dynamic>? ?? [])
          .map((e) => DichiarazioneStoricoComponente.fromJson(e as Map<String, dynamic>))
          .toList(),
      operatori: (json['operatori'] as List<dynamic>? ?? [])
          .map((e) => DichiarazioneOperatore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'idLinea': idLinea,
      'idMacchina': idMacchina,
      'dataProduzione': dataProduzione.toIso8601String(),
      'oraInizioProduzione': oraInizioProduzione?.toIso8601String(),
      'oraFineProduzione': oraFineProduzione?.toIso8601String(),
      'descrizionePF': descrizionePF,
      'lottoPF': lottoPF,
      'magazzinoPF': magazzinoPF,
      'quantitaProdotta': quantitaProdotta,
      'componenti': componenti.map((e) => e.toJson()).toList(),
      'operatori': operatori.map((e) => e.toJson()).toList(),
    };
  }
}

class DichiarazioneStoricoComponente {
  final int idRiga;
  final String codComponente;
  final String? descrizioneComponente;
  final String? unitaMisura;
  final double? quantitaDistinta;
  final double? quantitaProposta;
  double quantitaEffettiva;
  String? lotto;
  String magazzino;
  final bool gestioneLotti;
  List<LottoProduzione> lotti;

  DichiarazioneStoricoComponente({
    required this.idRiga,
    required this.codComponente,
    required this.descrizioneComponente,
    required this.unitaMisura,
    required this.quantitaDistinta,
    required this.quantitaProposta,
    required this.quantitaEffettiva,
    required this.lotto,
    required this.magazzino,
    required this.gestioneLotti,
    this.lotti = const [],
  });

  factory DichiarazioneStoricoComponente.fromJson(Map<String, dynamic> json) {
    return DichiarazioneStoricoComponente(
      idRiga: int.tryParse(json['idRiga']?.toString() ?? '') ?? 0,
      codComponente: json['codComponente']?.toString() ?? '',
      descrizioneComponente: json['descrizioneComponente']?.toString(),
      unitaMisura: json['unitaMisura']?.toString(),
      quantitaDistinta: json['quantitaDistinta'] == null ? null : _toDouble(json['quantitaDistinta']),
      quantitaProposta: json['quantitaProposta'] == null ? null : _toDouble(json['quantitaProposta']),
      quantitaEffettiva: _toDouble(json['quantitaEffettiva']),
      lotto: json['lotto']?.toString(),
      magazzino: json['magazzino']?.toString() ?? '',
      gestioneLotti: json['gestioneLotti'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRiga': idRiga,
      'codComponente': codComponente,
      'descrizioneComponente': descrizioneComponente,
      'unitaMisura': unitaMisura,
      'quantitaDistinta': quantitaDistinta,
      'quantitaProposta': quantitaProposta,
      'quantitaEffettiva': quantitaEffettiva,
      'lotto': lotto,
      'magazzino': magazzino,
      'gestioneLotti': gestioneLotti,
    };
  }
}






class OperatoreProduzione {
  final int idOperatore;
  final String codOperatore;
  final String nome;
  final String? cognome;
  final double? costoOrarioRiferimento;
  final DateTime? dataObsolescenza;
  final String? motivoObsolescenza;
  final bool attivo;

  const OperatoreProduzione({required this.idOperatore, required this.codOperatore, required this.nome, required this.cognome, required this.costoOrarioRiferimento, required this.dataObsolescenza, required this.motivoObsolescenza, required this.attivo});

  factory OperatoreProduzione.fromJson(Map<String, dynamic> json) {
    return OperatoreProduzione(
      idOperatore: int.tryParse(json['idOperatore']?.toString() ?? '') ?? 0,
      codOperatore: json['codOperatore']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      cognome: json['cognome']?.toString(),
      costoOrarioRiferimento: json['costoOrarioRiferimento'] == null ? null : _toDouble(json['costoOrarioRiferimento']),
      dataObsolescenza: json['dataObsolescenza'] == null ? null : DateTime.tryParse(json['dataObsolescenza'].toString()),
      motivoObsolescenza: json['motivoObsolescenza']?.toString(),
      attivo: json['attivo'] != false,
    );
  }

  String get label => [codOperatore, nome, cognome].where((e) => e != null && e.toString().trim().isNotEmpty).join(' - ');
}

class RuoloOperativo {
  final int idRuoloOperativo;
  final String codRuolo;
  final String descrizione;
  final bool attivo;

  const RuoloOperativo({required this.idRuoloOperativo, required this.codRuolo, required this.descrizione, required this.attivo});

  factory RuoloOperativo.fromJson(Map<String, dynamic> json) {
    return RuoloOperativo(
      idRuoloOperativo: int.tryParse(json['idRuoloOperativo']?.toString() ?? '') ?? 0,
      codRuolo: json['codRuolo']?.toString() ?? '',
      descrizione: json['descrizione']?.toString() ?? '',
      attivo: json['attivo'] != false,
    );
  }

  String get label => '$codRuolo - $descrizione';
}

class DichiarazioneOperatore {
  int? idOperatore;
  int? idRuoloOperativo;
  String? codOperatoreSnapshot;
  String? nomeOperatoreSnapshot;
  String? ruoloSnapshot;
  DateTime? oraInizio;
  DateTime? oraFine;
  double? costoOrarioApplicato;
  double? costoTotale;
  String? note;

  DichiarazioneOperatore({this.idOperatore, this.idRuoloOperativo, this.codOperatoreSnapshot, this.nomeOperatoreSnapshot, this.ruoloSnapshot, this.oraInizio, this.oraFine, this.costoOrarioApplicato, this.costoTotale, this.note});

  factory DichiarazioneOperatore.fromJson(Map<String, dynamic> json) {
    return DichiarazioneOperatore(
      idOperatore: json['idOperatore'] == null ? null : int.tryParse(json['idOperatore'].toString()),
      idRuoloOperativo: json['idRuoloOperativo'] == null ? null : int.tryParse(json['idRuoloOperativo'].toString()),
      codOperatoreSnapshot: json['codOperatoreSnapshot']?.toString(),
      nomeOperatoreSnapshot: json['nomeOperatoreSnapshot']?.toString(),
      ruoloSnapshot: json['ruoloSnapshot']?.toString(),
      oraInizio: json['oraInizio'] == null ? null : DateTime.tryParse(json['oraInizio'].toString()),
      oraFine: json['oraFine'] == null ? null : DateTime.tryParse(json['oraFine'].toString()),
      costoOrarioApplicato: json['costoOrarioApplicato'] == null ? null : _toDouble(json['costoOrarioApplicato']),
      costoTotale: json['costoTotale'] == null ? null : _toDouble(json['costoTotale']),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idOperatore': idOperatore,
      'idRuoloOperativo': idRuoloOperativo,
      'codOperatoreSnapshot': codOperatoreSnapshot,
      'nomeOperatoreSnapshot': nomeOperatoreSnapshot,
      'ruoloSnapshot': ruoloSnapshot,
      'oraInizio': oraInizio?.toIso8601String(),
      'oraFine': oraFine?.toIso8601String(),
      'costoOrarioApplicato': costoOrarioApplicato,
      'costoTotale': costoTotale,
      'note': note,
    };
  }
}



class MacchinaProduzione {
  final int idMacchina;
  final int? idLinea;
  final String? codLinea;
  final String? nomeLinea;
  final String codMacchina;
  final String nomeMacchina;
  final String? descrizione;
  final String? reparto;
  final String? costruttore;
  final String? modello;
  final String? matricola;
  final int? annoInstallazione;
  final String? stato;
  final String? unitaMisuraPrincipale;
  final double? velocitaNominale;
  final double? velocitaOttimale;
  final double? velocitaMassima;
  final double? capacitaMassimaTurno;
  final double? capacitaMassimaGiornaliera;
  final double? capacitaMassimaSettimanale;
  final double? tempoMinimoLottoMinuti;
  final double? tempoMassimoLottoMinuti;
  final double? costoAmmortamentoOra;
  final double? costoManutenzioneOra;
  final double? costoEnergiaVuotoOra;
  final double? costoEnergiaProduzioneOra;
  final double? costoLubrificantiOra;
  final double? costoUtensiliOra;
  final double? costoPuliziaOra;
  final double? costoFermoMacchinaOra;
  final double? costoOccupazioneSpazioOra;
  final double? tempoRiscaldamentoMinuti;
  final double? tempoRaffreddamentoMinuti;
  final double? tempoCambioFormatoStandardMinuti;
  final double? tempoPuliziaStandardMinuti;
  final double? tempoSanificazioneMinuti;
  final double? tempoSetupBaseMinuti;
  final double? tempoAvviamentoMinuti;
  final double? tempoArrestoMinuti;
  final double? consumoKwSpunto;
  final double? consumoKwFunzione;
  final double? unitaMinutoBenchmark;
  final String? noteTecniche;
  final bool attiva;

  const MacchinaProduzione({required this.idMacchina, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.codMacchina, required this.nomeMacchina, required this.descrizione, required this.reparto, required this.costruttore, required this.modello, required this.matricola, required this.annoInstallazione, required this.stato, required this.unitaMisuraPrincipale, required this.velocitaNominale, required this.velocitaOttimale, required this.velocitaMassima, required this.capacitaMassimaTurno, required this.capacitaMassimaGiornaliera, required this.capacitaMassimaSettimanale, required this.tempoMinimoLottoMinuti, required this.tempoMassimoLottoMinuti, required this.costoAmmortamentoOra, required this.costoManutenzioneOra, required this.costoEnergiaVuotoOra, required this.costoEnergiaProduzioneOra, required this.costoLubrificantiOra, required this.costoUtensiliOra, required this.costoPuliziaOra, required this.costoFermoMacchinaOra, required this.costoOccupazioneSpazioOra, required this.tempoRiscaldamentoMinuti, required this.tempoRaffreddamentoMinuti, required this.tempoCambioFormatoStandardMinuti, required this.tempoPuliziaStandardMinuti, required this.tempoSanificazioneMinuti, required this.tempoSetupBaseMinuti, required this.tempoAvviamentoMinuti, required this.tempoArrestoMinuti, required this.consumoKwSpunto, required this.consumoKwFunzione, required this.unitaMinutoBenchmark, required this.noteTecniche, required this.attiva});

  factory MacchinaProduzione.fromJson(Map<String, dynamic> json) => MacchinaProduzione(
    idMacchina: int.tryParse(json['idMacchina']?.toString() ?? '') ?? 0,
    idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    codMacchina: json['codMacchina']?.toString() ?? '',
    nomeMacchina: json['nomeMacchina']?.toString() ?? '',
    descrizione: json['descrizione']?.toString(),
    reparto: json['reparto']?.toString(),
    costruttore: json['costruttore']?.toString(),
    modello: json['modello']?.toString(),
    matricola: json['matricola']?.toString(),
    annoInstallazione: json['annoInstallazione'] == null ? null : int.tryParse(json['annoInstallazione'].toString()),
    stato: json['stato']?.toString(),
    unitaMisuraPrincipale: json['unitaMisuraPrincipale']?.toString(),
    velocitaNominale: json['velocitaNominale'] == null ? null : _toDouble(json['velocitaNominale']),
    velocitaOttimale: json['velocitaOttimale'] == null ? null : _toDouble(json['velocitaOttimale']),
    velocitaMassima: json['velocitaMassima'] == null ? null : _toDouble(json['velocitaMassima']),
    capacitaMassimaTurno: json['capacitaMassimaTurno'] == null ? null : _toDouble(json['capacitaMassimaTurno']),
    capacitaMassimaGiornaliera: json['capacitaMassimaGiornaliera'] == null ? null : _toDouble(json['capacitaMassimaGiornaliera']),
    capacitaMassimaSettimanale: json['capacitaMassimaSettimanale'] == null ? null : _toDouble(json['capacitaMassimaSettimanale']),
    tempoMinimoLottoMinuti: json['tempoMinimoLottoMinuti'] == null ? null : _toDouble(json['tempoMinimoLottoMinuti']),
    tempoMassimoLottoMinuti: json['tempoMassimoLottoMinuti'] == null ? null : _toDouble(json['tempoMassimoLottoMinuti']),
    costoAmmortamentoOra: json['costoAmmortamentoOra'] == null ? null : _toDouble(json['costoAmmortamentoOra']),
    costoManutenzioneOra: json['costoManutenzioneOra'] == null ? null : _toDouble(json['costoManutenzioneOra']),
    costoEnergiaVuotoOra: json['costoEnergiaVuotoOra'] == null ? null : _toDouble(json['costoEnergiaVuotoOra']),
    costoEnergiaProduzioneOra: json['costoEnergiaProduzioneOra'] == null ? null : _toDouble(json['costoEnergiaProduzioneOra']),
    costoLubrificantiOra: json['costoLubrificantiOra'] == null ? null : _toDouble(json['costoLubrificantiOra']),
    costoUtensiliOra: json['costoUtensiliOra'] == null ? null : _toDouble(json['costoUtensiliOra']),
    costoPuliziaOra: json['costoPuliziaOra'] == null ? null : _toDouble(json['costoPuliziaOra']),
    costoFermoMacchinaOra: json['costoFermoMacchinaOra'] == null ? null : _toDouble(json['costoFermoMacchinaOra']),
    costoOccupazioneSpazioOra: json['costoOccupazioneSpazioOra'] == null ? null : _toDouble(json['costoOccupazioneSpazioOra']),
    tempoRiscaldamentoMinuti: json['tempoRiscaldamentoMinuti'] == null ? null : _toDouble(json['tempoRiscaldamentoMinuti']),
    tempoRaffreddamentoMinuti: json['tempoRaffreddamentoMinuti'] == null ? null : _toDouble(json['tempoRaffreddamentoMinuti']),
    tempoCambioFormatoStandardMinuti: json['tempoCambioFormatoStandardMinuti'] == null ? null : _toDouble(json['tempoCambioFormatoStandardMinuti']),
    tempoPuliziaStandardMinuti: json['tempoPuliziaStandardMinuti'] == null ? null : _toDouble(json['tempoPuliziaStandardMinuti']),
    tempoSanificazioneMinuti: json['tempoSanificazioneMinuti'] == null ? null : _toDouble(json['tempoSanificazioneMinuti']),
    tempoSetupBaseMinuti: json['tempoSetupBaseMinuti'] == null ? null : _toDouble(json['tempoSetupBaseMinuti']),
    tempoAvviamentoMinuti: json['tempoAvviamentoMinuti'] == null ? null : _toDouble(json['tempoAvviamentoMinuti']),
    tempoArrestoMinuti: json['tempoArrestoMinuti'] == null ? null : _toDouble(json['tempoArrestoMinuti']),
    consumoKwSpunto: json['consumoKwSpunto'] == null ? null : _toDouble(json['consumoKwSpunto']),
    consumoKwFunzione: json['consumoKwFunzione'] == null ? null : _toDouble(json['consumoKwFunzione']),
    unitaMinutoBenchmark: json['unitaMinutoBenchmark'] == null ? null : _toDouble(json['unitaMinutoBenchmark']),
    noteTecniche: json['noteTecniche']?.toString(),
    attiva: json['attiva'] != false,
  );

  String get label => '$codMacchina - $nomeMacchina';
}

class SetupTipoProduzione {
  final int idSetupTipo;
  final String codSetupTipo;
  final String descrizione;
  final bool attivo;

  const SetupTipoProduzione({required this.idSetupTipo, required this.codSetupTipo, required this.descrizione, required this.attivo});

  factory SetupTipoProduzione.fromJson(Map<String, dynamic> json) => SetupTipoProduzione(
    idSetupTipo: int.tryParse(json['idSetupTipo']?.toString() ?? '') ?? 0,
    codSetupTipo: json['codSetupTipo']?.toString() ?? '',
    descrizione: json['descrizione']?.toString() ?? '',
    attivo: json['attivo'] != false,
  );

  String get label => '$codSetupTipo - $descrizione';
}

class SetupRegolaProduzione {
  final int idSetupRegola;
  final int idSetupTipo;
  final String codSetupTipo;
  final String setupDescrizione;
  final int? idLinea;
  final String? codLinea;
  final String? nomeLinea;
  final int? idMacchina;
  final String? codMacchina;
  final String? nomeMacchina;
  final String? codArticolo;
  final double? tempoStandardMinuti;
  final double? costoStandard;
  final int priorita;
  final DateTime? validoDal;
  final DateTime? validoAl;
  final bool attiva;

  const SetupRegolaProduzione({required this.idSetupRegola, required this.idSetupTipo, required this.codSetupTipo, required this.setupDescrizione, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.idMacchina, required this.codMacchina, required this.nomeMacchina, required this.codArticolo, required this.tempoStandardMinuti, required this.costoStandard, required this.priorita, required this.validoDal, required this.validoAl, required this.attiva});

  factory SetupRegolaProduzione.fromJson(Map<String, dynamic> json) => SetupRegolaProduzione(
    idSetupRegola: int.tryParse(json['idSetupRegola']?.toString() ?? '') ?? 0,
    idSetupTipo: int.tryParse(json['idSetupTipo']?.toString() ?? '') ?? 0,
    codSetupTipo: json['codSetupTipo']?.toString() ?? '',
    setupDescrizione: json['setupDescrizione']?.toString() ?? '',
    idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    codArticolo: json['codArticolo']?.toString(),
    tempoStandardMinuti: json['tempoStandardMinuti'] == null ? null : _toDouble(json['tempoStandardMinuti']),
    costoStandard: json['costoStandard'] == null ? null : _toDouble(json['costoStandard']),
    priorita: int.tryParse(json['priorita']?.toString() ?? '') ?? 100,
    validoDal: json['validoDal'] == null ? null : DateTime.tryParse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
    attiva: json['attiva'] != false,
  );
}





class TeamOperativo {
  final int idTeam;
  final String codTeam;
  final String descrizione;
  final String? note;
  final bool attivo;

  const TeamOperativo({required this.idTeam, required this.codTeam, required this.descrizione, required this.note, required this.attivo});

  factory TeamOperativo.fromJson(Map<String, dynamic> json) => TeamOperativo(
    idTeam: int.tryParse(json['idTeam']?.toString() ?? '') ?? 0,
    codTeam: json['codTeam']?.toString() ?? '',
    descrizione: json['descrizione']?.toString() ?? '',
    note: json['note']?.toString(),
    attivo: json['attivo'] != false,
  );

  String get label => '$codTeam - $descrizione';
}

class TeamOperatore {
  final int idTeamOperatore;
  final int idTeam;
  final int idOperatore;
  final String codOperatore;
  final String nome;
  final String? cognome;
  final int? idRuoloOperativo;
  final String? codRuolo;
  final String? ruoloDescrizione;
  final double? costoOrarioApplicato;
  final String? note;
  final DateTime? validoDal;
  final DateTime? validoAl;
  final bool attivo;

  const TeamOperatore({required this.idTeamOperatore, required this.idTeam, required this.idOperatore, required this.codOperatore, required this.nome, required this.cognome, required this.idRuoloOperativo, required this.codRuolo, required this.ruoloDescrizione, required this.costoOrarioApplicato, required this.note, required this.validoDal, required this.validoAl, required this.attivo});

  factory TeamOperatore.fromJson(Map<String, dynamic> json) => TeamOperatore(
    idTeamOperatore: int.tryParse(json['idTeamOperatore']?.toString() ?? '') ?? 0,
    idTeam: int.tryParse(json['idTeam']?.toString() ?? '') ?? 0,
    idOperatore: int.tryParse(json['idOperatore']?.toString() ?? '') ?? 0,
    codOperatore: json['codOperatore']?.toString() ?? '',
    nome: json['nome']?.toString() ?? '',
    cognome: json['cognome']?.toString(),
    idRuoloOperativo: json['idRuoloOperativo'] == null ? null : int.tryParse(json['idRuoloOperativo'].toString()),
    codRuolo: json['codRuolo']?.toString(),
    ruoloDescrizione: json['ruoloDescrizione']?.toString(),
    costoOrarioApplicato: json['costoOrarioApplicato'] == null ? null : _toDouble(json['costoOrarioApplicato']),
    note: json['note']?.toString(),
    validoDal: json['validoDal'] == null ? null : DateTime.tryParse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
    attivo: json['attivo'] != false,
  );

  String get nomeCompleto => [nome, cognome].where((e) => e != null && e.trim().isNotEmpty).join(' ');
}

class CostoLineaProduzione {
  final int idCostoLinea;
  final int idLinea;
  final String codLinea;
  final String nomeLinea;
  final int? idMacchina;
  final String? codMacchina;
  final String? nomeMacchina;
  final DateTime validoDal;
  final DateTime? validoAl;
  final double? costoFissoOra;
  final double? costoMacchinaOra;
  final double? costoManodoperaOra;
  final double? costoEnergiaOra;
  final double? costoEnergiaUnita;
  final String? note;
  final bool attivo;

  const CostoLineaProduzione({required this.idCostoLinea, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.idMacchina, required this.codMacchina, required this.nomeMacchina, required this.validoDal, required this.validoAl, required this.costoFissoOra, required this.costoMacchinaOra, required this.costoManodoperaOra, required this.costoEnergiaOra, required this.costoEnergiaUnita, required this.note, required this.attivo});

  factory CostoLineaProduzione.fromJson(Map<String, dynamic> json) => CostoLineaProduzione(
    idCostoLinea: int.tryParse(json['idCostoLinea']?.toString() ?? '') ?? 0,
    idLinea: int.tryParse(json['idLinea']?.toString() ?? '') ?? 0,
    codLinea: json['codLinea']?.toString() ?? '',
    nomeLinea: json['nomeLinea']?.toString() ?? '',
    idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    validoDal: DateTime.parse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
    costoFissoOra: json['costoFissoOra'] == null ? null : _toDouble(json['costoFissoOra']),
    costoMacchinaOra: json['costoMacchinaOra'] == null ? null : _toDouble(json['costoMacchinaOra']),
    costoManodoperaOra: json['costoManodoperaOra'] == null ? null : _toDouble(json['costoManodoperaOra']),
    costoEnergiaOra: json['costoEnergiaOra'] == null ? null : _toDouble(json['costoEnergiaOra']),
    costoEnergiaUnita: json['costoEnergiaUnita'] == null ? null : _toDouble(json['costoEnergiaUnita']),
    note: json['note']?.toString(),
    attivo: json['attivo'] != false,
  );
}






class ProcessoProduttivo {
  final int idProcesso;
  final String codProcesso;
  final String? codArticolo;
  final String descrizione;
  final String? note;
  final String stato;
  final int? idVersioneCorrente;
  final int? numeroVersioneCorrente;
  final DateTime? validoDal;
  final DateTime? validoAl;

  const ProcessoProduttivo({required this.idProcesso, required this.codProcesso, required this.codArticolo, required this.descrizione, required this.note, required this.stato, required this.idVersioneCorrente, required this.numeroVersioneCorrente, required this.validoDal, required this.validoAl});

  factory ProcessoProduttivo.fromJson(Map<String, dynamic> json) => ProcessoProduttivo(
    idProcesso: int.tryParse(json['idProcesso']?.toString() ?? '') ?? 0,
    codProcesso: json['codProcesso']?.toString() ?? '',
    codArticolo: json['codArticolo']?.toString(),
    descrizione: json['descrizione']?.toString() ?? '',
    note: json['note']?.toString(),
    stato: json['stato']?.toString() ?? '',
    idVersioneCorrente: json['idVersioneCorrente'] == null ? null : int.tryParse(json['idVersioneCorrente'].toString()),
    numeroVersioneCorrente: json['numeroVersioneCorrente'] == null ? null : int.tryParse(json['numeroVersioneCorrente'].toString()),
    validoDal: json['validoDal'] == null ? null : DateTime.tryParse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
  );

  String get label => '$codProcesso - $descrizione';
}

class VersioneProcesso {
  final int idVersione;
  final int idProcesso;
  final int numeroVersione;
  final String? descrizione;
  final String? motivazione;
  final DateTime validoDal;
  final DateTime? validoAl;
  final String stato;
  final double? tempoAttesoMinuti;
  final double? setupAttesoMinuti;
  final double? produttivitaAttesa;
  final double? costoAtteso;
  final double? energiaAttesa;

  const VersioneProcesso({required this.idVersione, required this.idProcesso, required this.numeroVersione, required this.descrizione, required this.motivazione, required this.validoDal, required this.validoAl, required this.stato, required this.tempoAttesoMinuti, required this.setupAttesoMinuti, required this.produttivitaAttesa, required this.costoAtteso, required this.energiaAttesa});

  factory VersioneProcesso.fromJson(Map<String, dynamic> json) => VersioneProcesso(
    idVersione: int.tryParse(json['idVersione']?.toString() ?? '') ?? 0,
    idProcesso: int.tryParse(json['idProcesso']?.toString() ?? '') ?? 0,
    numeroVersione: int.tryParse(json['numeroVersione']?.toString() ?? '') ?? 0,
    descrizione: json['descrizione']?.toString(),
    motivazione: json['motivazione']?.toString(),
    validoDal: DateTime.parse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
    stato: json['stato']?.toString() ?? '',
    tempoAttesoMinuti: json['tempoAttesoMinuti'] == null ? null : _toDouble(json['tempoAttesoMinuti']),
    setupAttesoMinuti: json['setupAttesoMinuti'] == null ? null : _toDouble(json['setupAttesoMinuti']),
    produttivitaAttesa: json['produttivitaAttesa'] == null ? null : _toDouble(json['produttivitaAttesa']),
    costoAtteso: json['costoAtteso'] == null ? null : _toDouble(json['costoAtteso']),
    energiaAttesa: json['energiaAttesa'] == null ? null : _toDouble(json['energiaAttesa']),
  );
}

class FaseProcesso {
  final int idFase;
  final int idVersione;
  final int sequenza;
  final String codFase;
  final String descrizione;
  final int? idLineaDefault;
  final String? codLinea;
  final String? nomeLinea;
  final int? idMacchinaDefault;
  final String? codMacchina;
  final String? nomeMacchina;
  final double? tempoStandardMinuti;
  final double? setupStandardMinuti;
  final double? produttivitaAttesa;
  final double? costoStandard;
  final double? energiaAttesa;
  final double? qualitaAttesa;
  final double? scartoAtteso;
  final String? note;
  final bool richiedeMacchina;
  final bool richiedeTeam;
  final bool richiedeSetup;
  final bool richiedeOrari;
  final bool richiedeArticolo;
  final bool richiedeLotto;
  final bool richiedeComponenti;
  final bool richiedeControlloQualita;
  final bool richiedeNote;
  final bool generaErp;
  final bool generaCaricoPf;
  final bool generaScaricoComponenti;

  const FaseProcesso({required this.idFase, required this.idVersione, required this.sequenza, required this.codFase, required this.descrizione, required this.idLineaDefault, required this.codLinea, required this.nomeLinea, required this.idMacchinaDefault, required this.codMacchina, required this.nomeMacchina, required this.tempoStandardMinuti, required this.setupStandardMinuti, required this.produttivitaAttesa, required this.costoStandard, required this.energiaAttesa, required this.qualitaAttesa, required this.scartoAtteso, required this.note, required this.richiedeMacchina, required this.richiedeTeam, required this.richiedeSetup, required this.richiedeOrari, required this.richiedeArticolo, required this.richiedeLotto, required this.richiedeComponenti, required this.richiedeControlloQualita, required this.richiedeNote, required this.generaErp, required this.generaCaricoPf, required this.generaScaricoComponenti});

  factory FaseProcesso.fromJson(Map<String, dynamic> json) => FaseProcesso(
    idFase: int.tryParse(json['idFase']?.toString() ?? '') ?? 0,
    idVersione: int.tryParse(json['idVersione']?.toString() ?? '') ?? 0,
    sequenza: int.tryParse(json['sequenza']?.toString() ?? '') ?? 0,
    codFase: json['codFase']?.toString() ?? '',
    descrizione: json['descrizione']?.toString() ?? '',
    idLineaDefault: json['idLineaDefault'] == null ? null : int.tryParse(json['idLineaDefault'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    idMacchinaDefault: json['idMacchinaDefault'] == null ? null : int.tryParse(json['idMacchinaDefault'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    tempoStandardMinuti: json['tempoStandardMinuti'] == null ? null : _toDouble(json['tempoStandardMinuti']),
    setupStandardMinuti: json['setupStandardMinuti'] == null ? null : _toDouble(json['setupStandardMinuti']),
    produttivitaAttesa: json['produttivitaAttesa'] == null ? null : _toDouble(json['produttivitaAttesa']),
    costoStandard: json['costoStandard'] == null ? null : _toDouble(json['costoStandard']),
    energiaAttesa: json['energiaAttesa'] == null ? null : _toDouble(json['energiaAttesa']),
    qualitaAttesa: json['qualitaAttesa'] == null ? null : _toDouble(json['qualitaAttesa']),
    scartoAtteso: json['scartoAtteso'] == null ? null : _toDouble(json['scartoAtteso']),
    note: json['note']?.toString(),
    richiedeMacchina: _toBool(json['richiedeMacchina'], fallback: true),
    richiedeTeam: _toBool(json['richiedeTeam'], fallback: true),
    richiedeSetup: _toBool(json['richiedeSetup']),
    richiedeOrari: _toBool(json['richiedeOrari'], fallback: true),
    richiedeArticolo: _toBool(json['richiedeArticolo'], fallback: true),
    richiedeLotto: _toBool(json['richiedeLotto'], fallback: true),
    richiedeComponenti: _toBool(json['richiedeComponenti'], fallback: true),
    richiedeControlloQualita: _toBool(json['richiedeControlloQualita']),
    richiedeNote: _toBool(json['richiedeNote']),
    generaErp: _toBool(json['generaErp'], fallback: true),
    generaCaricoPf: _toBool(json['generaCaricoPf'], fallback: true),
    generaScaricoComponenti: _toBool(json['generaScaricoComponenti'], fallback: true),
  );

  String get label => '$codFase - $descrizione';
}

class AttivitaProduttiva {
  final int idAttivita;
  final int idVersione;
  final int? idProcesso;
  final String? codProcesso;
  final String? processoDescrizione;
  final int? idFase;
  final String? codFase;
  final String? faseDescrizione;
  final int? idDichiarazione;
  final DateTime dataProduzione;
  final String stato;
  final String? codArticolo;
  final double? quantitaPrevista;
  final double? quantitaConsuntivata;
  final int? idLinea;
  final String? codLinea;
  final String? nomeLinea;
  final int? idMacchina;
  final String? codMacchina;
  final String? nomeMacchina;
  final int? idTeam;
  final String? codTeam;
  final DateTime? oraInizio;
  final DateTime? oraFine;
  final String? note;

  const AttivitaProduttiva({required this.idAttivita, required this.idVersione, required this.idProcesso, required this.codProcesso, required this.processoDescrizione, required this.idFase, required this.codFase, required this.faseDescrizione, required this.idDichiarazione, required this.dataProduzione, required this.stato, required this.codArticolo, required this.quantitaPrevista, required this.quantitaConsuntivata, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.idMacchina, required this.codMacchina, required this.nomeMacchina, required this.idTeam, required this.codTeam, required this.oraInizio, required this.oraFine, required this.note});

  factory AttivitaProduttiva.fromJson(Map<String, dynamic> json) => AttivitaProduttiva(
    idAttivita: int.tryParse(json['idAttivita']?.toString() ?? '') ?? 0,
    idVersione: int.tryParse(json['idVersione']?.toString() ?? '') ?? 0,
    idProcesso: json['idProcesso'] == null ? null : int.tryParse(json['idProcesso'].toString()),
    codProcesso: json['codProcesso']?.toString(),
    processoDescrizione: json['processoDescrizione']?.toString(),
    idFase: json['idFase'] == null ? null : int.tryParse(json['idFase'].toString()),
    codFase: json['codFase']?.toString(),
    faseDescrizione: json['faseDescrizione']?.toString(),
    idDichiarazione: json['idDichiarazione'] == null ? null : int.tryParse(json['idDichiarazione'].toString()),
    dataProduzione: DateTime.parse(json['dataProduzione'].toString()),
    stato: json['stato']?.toString() ?? '',
    codArticolo: json['codArticolo']?.toString(),
    quantitaPrevista: json['quantitaPrevista'] == null ? null : _toDouble(json['quantitaPrevista']),
    quantitaConsuntivata: json['quantitaConsuntivata'] == null ? null : _toDouble(json['quantitaConsuntivata']),
    idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    idTeam: json['idTeam'] == null ? null : int.tryParse(json['idTeam'].toString()),
    codTeam: json['codTeam']?.toString(),
    oraInizio: json['oraInizio'] == null ? null : DateTime.tryParse(json['oraInizio'].toString()),
    oraFine: json['oraFine'] == null ? null : DateTime.tryParse(json['oraFine'].toString()),
    note: json['note']?.toString(),
  );
}class FaseRisorsaProcesso {
  final int idFaseRisorsa;
  final int idFase;
  final int? idLinea;
  final String? codLinea;
  final String? nomeLinea;
  final int? idMacchina;
  final String? codMacchina;
  final String? nomeMacchina;
  final int? idTeam;
  final String? codTeam;
  final String? teamDescrizione;
  final DateTime validoDal;
  final DateTime? validoAl;
  final double? velocitaReale;
  final double? tempoSetupAggiuntivoMinuti;
  final double? scartoMedio;
  final double? energiaAggiuntiva;
  final int? operatoriMinimi;
  final int? operatoriConsigliati;
  final String? competenzeRichieste;
  final String? note;

  const FaseRisorsaProcesso({required this.idFaseRisorsa, required this.idFase, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.idMacchina, required this.codMacchina, required this.nomeMacchina, required this.idTeam, required this.codTeam, required this.teamDescrizione, required this.validoDal, required this.validoAl, required this.velocitaReale, required this.tempoSetupAggiuntivoMinuti, required this.scartoMedio, required this.energiaAggiuntiva, required this.operatoriMinimi, required this.operatoriConsigliati, required this.competenzeRichieste, required this.note});

  factory FaseRisorsaProcesso.fromJson(Map<String, dynamic> json) => FaseRisorsaProcesso(
    idFaseRisorsa: int.tryParse(json['idFaseRisorsa']?.toString() ?? '') ?? 0,
    idFase: int.tryParse(json['idFase']?.toString() ?? '') ?? 0,
    idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    idTeam: json['idTeam'] == null ? null : int.tryParse(json['idTeam'].toString()),
    codTeam: json['codTeam']?.toString(),
    teamDescrizione: json['teamDescrizione']?.toString(),
    validoDal: DateTime.parse(json['validoDal'].toString()),
    validoAl: json['validoAl'] == null ? null : DateTime.tryParse(json['validoAl'].toString()),
    velocitaReale: json['velocitaReale'] == null ? null : _toDouble(json['velocitaReale']),
    tempoSetupAggiuntivoMinuti: json['tempoSetupAggiuntivoMinuti'] == null ? null : _toDouble(json['tempoSetupAggiuntivoMinuti']),
    scartoMedio: json['scartoMedio'] == null ? null : _toDouble(json['scartoMedio']),
    energiaAggiuntiva: json['energiaAggiuntiva'] == null ? null : _toDouble(json['energiaAggiuntiva']),
    operatoriMinimi: json['operatoriMinimi'] == null ? null : int.tryParse(json['operatoriMinimi'].toString()),
    operatoriConsigliati: json['operatoriConsigliati'] == null ? null : int.tryParse(json['operatoriConsigliati'].toString()),
    competenzeRichieste: json['competenzeRichieste']?.toString(),
    note: json['note']?.toString(),
  );

  String get label => '${codTeam ?? 'Team -'} • ${codLinea ?? 'Linea -'} • ${codMacchina ?? 'Macchina -'}';
}





class ChiusuraFase {
  final int idChiusuraFase;
  final int? idAttivita;
  final int idFase;
  final DateTime dataChiusura;
  final String stato;
  final int? idLinea;
  final String? codLinea;
  final String? nomeLinea;
  final int? idMacchina;
  final String? codMacchina;
  final String? nomeMacchina;
  final int? idTeam;
  final String? codTeam;
  final String? teamDescrizione;
  final DateTime? oraInizio;
  final DateTime? oraFine;
  final String? codArticolo;
  final String? descrizioneArticolo;
  final String? lotto;
  final String? magazzino;
  final double? quantita;
  final String? note;
  final bool generatoErp;
  final String? serialCaricoAdhoc;
  final int? numeroCaricoAdhoc;
  final String? serialScaricoAdhoc;
  final int? numeroScaricoAdhoc;
  final List<ChiusuraFaseComponente> componenti;

  const ChiusuraFase({required this.idChiusuraFase, required this.idAttivita, required this.idFase, required this.dataChiusura, required this.stato, required this.idLinea, required this.codLinea, required this.nomeLinea, required this.idMacchina, required this.codMacchina, required this.nomeMacchina, required this.idTeam, required this.codTeam, required this.teamDescrizione, required this.oraInizio, required this.oraFine, required this.codArticolo, required this.descrizioneArticolo, required this.lotto, required this.magazzino, required this.quantita, required this.note, required this.generatoErp, required this.serialCaricoAdhoc, required this.numeroCaricoAdhoc, required this.serialScaricoAdhoc, required this.numeroScaricoAdhoc, required this.componenti});

  factory ChiusuraFase.fromJson(Map<String, dynamic> json) => ChiusuraFase(
    idChiusuraFase: int.tryParse(json['idChiusuraFase']?.toString() ?? '') ?? 0,
    idAttivita: json['idAttivita'] == null ? null : int.tryParse(json['idAttivita'].toString()),
    idFase: int.tryParse(json['idFase']?.toString() ?? '') ?? 0,
    dataChiusura: DateTime.parse(json['dataChiusura'].toString()),
    stato: json['stato']?.toString() ?? '',
    idLinea: json['idLinea'] == null ? null : int.tryParse(json['idLinea'].toString()),
    codLinea: json['codLinea']?.toString(),
    nomeLinea: json['nomeLinea']?.toString(),
    idMacchina: json['idMacchina'] == null ? null : int.tryParse(json['idMacchina'].toString()),
    codMacchina: json['codMacchina']?.toString(),
    nomeMacchina: json['nomeMacchina']?.toString(),
    idTeam: json['idTeam'] == null ? null : int.tryParse(json['idTeam'].toString()),
    codTeam: json['codTeam']?.toString(),
    teamDescrizione: json['teamDescrizione']?.toString(),
    oraInizio: json['oraInizio'] == null ? null : DateTime.tryParse(json['oraInizio'].toString()),
    oraFine: json['oraFine'] == null ? null : DateTime.tryParse(json['oraFine'].toString()),
    codArticolo: json['codArticolo']?.toString(),
    descrizioneArticolo: json['descrizioneArticolo']?.toString(),
    lotto: json['lotto']?.toString(),
    magazzino: json['magazzino']?.toString(),
    quantita: json['quantita'] == null ? null : _toDouble(json['quantita']),
    note: json['note']?.toString(),
    generatoErp: _toBool(json['generatoErp']),
    serialCaricoAdhoc: json['serialCaricoAdhoc']?.toString(),
    numeroCaricoAdhoc: json['numeroCaricoAdhoc'] == null ? null : int.tryParse(json['numeroCaricoAdhoc'].toString()),
    serialScaricoAdhoc: json['serialScaricoAdhoc']?.toString(),
    numeroScaricoAdhoc: json['numeroScaricoAdhoc'] == null ? null : int.tryParse(json['numeroScaricoAdhoc'].toString()),
    componenti: (json['componenti'] as List<dynamic>? ?? []).map((e) => ChiusuraFaseComponente.fromJson(e as Map<String, dynamic>)).toList(),
  );

  String get macchinaLabel => [codMacchina, nomeMacchina].where((e) => e != null && e.trim().isNotEmpty).join(' - ');
  String get teamLabel => [codTeam, teamDescrizione].where((e) => e != null && e.trim().isNotEmpty).join(' - ');
}

class ChiusuraFaseComponente {
  final String codComponente;
  final String? descrizioneComponente;
  final String? unitaMisura;
  final double quantita;
  final String? lotto;
  final String? magazzino;

  const ChiusuraFaseComponente({required this.codComponente, required this.descrizioneComponente, required this.unitaMisura, required this.quantita, required this.lotto, required this.magazzino});

  factory ChiusuraFaseComponente.fromJson(Map<String, dynamic> json) => ChiusuraFaseComponente(
    codComponente: json['codComponente']?.toString() ?? '',
    descrizioneComponente: json['descrizioneComponente']?.toString(),
    unitaMisura: json['unitaMisura']?.toString(),
    quantita: _toDouble(json['quantita']),
    lotto: json['lotto']?.toString(),
    magazzino: json['magazzino']?.toString(),
  );

  ComponenteDistinta toComponenteDistinta() => ComponenteDistinta(
    codComponente: codComponente,
    descrizione: descrizioneComponente ?? '',
    unitaMisura: unitaMisura ?? '',
    quantitaDistinta: 0,
    quantitaProposta: quantita,
    quantitaDaScaricare: quantita,
    magazzino: magazzino ?? '01',
    gestioneLotti: lotto != null && lotto!.trim().isNotEmpty,
    lotto: lotto,
  );
}
