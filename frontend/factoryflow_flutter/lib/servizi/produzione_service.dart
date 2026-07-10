import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../modelli/produzione.dart';

class ProduzioneService {
  Future<ConfigurazioneAttiva> getConfigurazioneAttiva() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/configurazione/attiva');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore configurazione ${res.statusCode}: ${res.body}');
    }

    return ConfigurazioneAttiva.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<List<LineaProduzione>> getLinee({bool soloAttive = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/linee');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore linee ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    final linee = data
        .map((e) => LineaProduzione.fromJson(e as Map<String, dynamic>))
        .toList();
    return soloAttive ? linee.where((e) => e.attiva).toList() : linee;
  }

  Future<void> salvaLinea({
    int? idLinea,
    required String codLinea,
    required String nomeLinea,
    String? descrizioneFunzionale,
    bool attiva = true,
  }) async {
    final uri = idLinea == null
        ? Uri.parse('${AppConfig.baseUrl}/api/linee')
        : Uri.parse('${AppConfig.baseUrl}/api/linee/$idLinea');
    final body = jsonEncode({
      'codLinea': codLinea,
      'nomeLinea': nomeLinea,
      'descrizioneFunzionale': descrizioneFunzionale,
      'attiva': attiva,
    });
    final res = idLinea == null
        ? await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        : await http.put(uri, headers: {'Content-Type': 'application/json'}, body: body);

    if (res.statusCode != 200) {
      throw Exception('Errore salvataggio linea ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> associaArticoloLinea(int idLinea, String codArticolo) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/linee/$idLinea/articoli');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codArticolo': codArticolo, 'attivo': true}),
    );

    if (res.statusCode != 204) {
      throw Exception('Errore associazione articolo ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> rimuoviArticoloLinea(int idLinea, String codArticolo) async {
    final encodedCodArticolo = Uri.encodeComponent(codArticolo);
    final uri = Uri.parse('${AppConfig.baseUrl}/api/linee/$idLinea/articoli/$encodedCodArticolo');
    final res = await http.delete(uri);

    if (res.statusCode != 204) {
      throw Exception('Errore rimozione articolo ${res.statusCode}: ${res.body}');
    }
  }

  Future<List<OperatoreProduzione>> getOperatori({bool soloAttivi = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/operatori');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore operatori ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    final rows = data.map((e) => OperatoreProduzione.fromJson(e as Map<String, dynamic>)).toList();
    return soloAttivi ? rows.where((e) => e.attivo).toList() : rows;
  }

  Future<List<RuoloOperativo>> getRuoliOperativi() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/ruoli-operativi');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore ruoli operativi ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => RuoloOperativo.fromJson(e as Map<String, dynamic>)).where((e) => e.attivo).toList();
  }
  Future<void> salvaOperatore({
    int? idOperatore,
    required String codOperatore,
    required String nome,
    String? cognome,
    double? costoOrarioRiferimento,
    bool attivo = true,
    DateTime? dataObsolescenza,
    String? motivoObsolescenza,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/operatori');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idOperatore': idOperatore, 'codOperatore': codOperatore, 'nome': nome, 'cognome': cognome, 'costoOrarioRiferimento': costoOrarioRiferimento, 'attivo': attivo, 'dataObsolescenza': dataObsolescenza?.toIso8601String(), 'motivoObsolescenza': motivoObsolescenza}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio operatore ${res.statusCode}: ${res.body}');
  }

  Future<void> salvaRuoloOperativo({int? idRuoloOperativo, required String codRuolo, required String descrizione, bool attivo = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/ruoli-operativi');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idRuoloOperativo': idRuoloOperativo, 'codRuolo': codRuolo, 'descrizione': descrizione, 'attivo': attivo}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio ruolo ${res.statusCode}: ${res.body}');
  }

  Future<List<MacchinaProduzione>> getMacchine() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/macchine'));
    if (res.statusCode != 200) throw Exception('Errore macchine ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => MacchinaProduzione.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaMacchina({
    int? idMacchina,
    int? idLinea,
    required String codMacchina,
    required String nomeMacchina,
    String? descrizione,
    String? reparto,
    String? costruttore,
    String? modello,
    String? matricola,
    int? annoInstallazione,
    String? stato,
    String? unitaMisuraPrincipale,
    double? velocitaNominale,
    double? velocitaOttimale,
    double? velocitaMassima,
    double? capacitaMassimaTurno,
    double? capacitaMassimaGiornaliera,
    double? capacitaMassimaSettimanale,
    double? tempoMinimoLottoMinuti,
    double? tempoMassimoLottoMinuti,
    double? costoAmmortamentoOra,
    double? costoManutenzioneOra,
    double? costoEnergiaVuotoOra,
    double? costoEnergiaProduzioneOra,
    double? costoLubrificantiOra,
    double? costoUtensiliOra,
    double? costoPuliziaOra,
    double? costoFermoMacchinaOra,
    double? costoOccupazioneSpazioOra,
    double? tempoRiscaldamentoMinuti,
    double? tempoRaffreddamentoMinuti,
    double? tempoCambioFormatoStandardMinuti,
    double? tempoPuliziaStandardMinuti,
    double? tempoSanificazioneMinuti,
    double? tempoSetupBaseMinuti,
    double? tempoAvviamentoMinuti,
    double? tempoArrestoMinuti,
    double? consumoKwSpunto,
    double? consumoKwFunzione,
    double? unitaMinutoBenchmark,
    String? noteTecniche,
    bool attiva = true,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/macchine');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'idMacchina': idMacchina,
      'idLinea': idLinea,
      'codMacchina': codMacchina,
      'nomeMacchina': nomeMacchina,
      'descrizione': descrizione,
      'reparto': reparto,
      'costruttore': costruttore,
      'modello': modello,
      'matricola': matricola,
      'annoInstallazione': annoInstallazione,
      'stato': stato,
      'unitaMisuraPrincipale': unitaMisuraPrincipale,
      'velocitaNominale': velocitaNominale,
      'velocitaOttimale': velocitaOttimale,
      'velocitaMassima': velocitaMassima,
      'capacitaMassimaTurno': capacitaMassimaTurno,
      'capacitaMassimaGiornaliera': capacitaMassimaGiornaliera,
      'capacitaMassimaSettimanale': capacitaMassimaSettimanale,
      'tempoMinimoLottoMinuti': tempoMinimoLottoMinuti,
      'tempoMassimoLottoMinuti': tempoMassimoLottoMinuti,
      'costoAmmortamentoOra': costoAmmortamentoOra,
      'costoManutenzioneOra': costoManutenzioneOra,
      'costoEnergiaVuotoOra': costoEnergiaVuotoOra,
      'costoEnergiaProduzioneOra': costoEnergiaProduzioneOra,
      'costoLubrificantiOra': costoLubrificantiOra,
      'costoUtensiliOra': costoUtensiliOra,
      'costoPuliziaOra': costoPuliziaOra,
      'costoFermoMacchinaOra': costoFermoMacchinaOra,
      'costoOccupazioneSpazioOra': costoOccupazioneSpazioOra,
      'tempoRiscaldamentoMinuti': tempoRiscaldamentoMinuti,
      'tempoRaffreddamentoMinuti': tempoRaffreddamentoMinuti,
      'tempoCambioFormatoStandardMinuti': tempoCambioFormatoStandardMinuti,
      'tempoPuliziaStandardMinuti': tempoPuliziaStandardMinuti,
      'tempoSanificazioneMinuti': tempoSanificazioneMinuti,
      'tempoSetupBaseMinuti': tempoSetupBaseMinuti,
      'tempoAvviamentoMinuti': tempoAvviamentoMinuti,
      'tempoArrestoMinuti': tempoArrestoMinuti,
      'consumoKwSpunto': consumoKwSpunto,
      'consumoKwFunzione': consumoKwFunzione,
      'unitaMinutoBenchmark': unitaMinutoBenchmark,
      'noteTecniche': noteTecniche,
      'attiva': attiva,
    }));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio macchina ${res.statusCode}: ${res.body}');
  }

  Future<List<SetupTipoProduzione>> getSetupTipi() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/setup-tipi'));
    if (res.statusCode != 200) throw Exception('Errore tipi setup ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => SetupTipoProduzione.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaSetupTipo({int? idSetupTipo, required String codSetupTipo, required String descrizione, bool attivo = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/setup-tipi');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idSetupTipo': idSetupTipo, 'codSetupTipo': codSetupTipo, 'descrizione': descrizione, 'attivo': attivo}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio tipo setup ${res.statusCode}: ${res.body}');
  }

  Future<List<SetupRegolaProduzione>> getSetupRegole() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/setup-regole'));
    if (res.statusCode != 200) throw Exception('Errore regole setup ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => SetupRegolaProduzione.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaSetupRegola({int? idSetupRegola, required int idSetupTipo, int? idLinea, int? idMacchina, String? codArticolo, double? tempoStandardMinuti, double? costoStandard, int priorita = 100, bool attiva = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/setup-regole');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idSetupRegola': idSetupRegola, 'idSetupTipo': idSetupTipo, 'idLinea': idLinea, 'idMacchina': idMacchina, 'codArticolo': codArticolo, 'tempoStandardMinuti': tempoStandardMinuti, 'costoStandard': costoStandard, 'priorita': priorita, 'attiva': attiva}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio regola setup ${res.statusCode}: ${res.body}');
  }

  Future<List<TeamOperativo>> getTeamOperativi() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/team-operativi'));
    if (res.statusCode != 200) throw Exception('Errore team operativi ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => TeamOperativo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaTeamOperativo({int? idTeam, required String codTeam, required String descrizione, String? note, bool attivo = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/team-operativi');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idTeam': idTeam, 'codTeam': codTeam, 'descrizione': descrizione, 'note': note, 'attivo': attivo}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio team ${res.statusCode}: ${res.body}');
  }

  Future<List<TeamOperatore>> getTeamOperatori(int idTeam) async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/team-operativi/$idTeam/operatori'));
    if (res.statusCode != 200) throw Exception('Errore operatori team ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => TeamOperatore.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaTeamOperatore({int? idTeamOperatore, required int idTeam, required int idOperatore, int? idRuoloOperativo, double? costoOrarioApplicato, String? note, bool attivo = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/team-operativi/$idTeam/operatori');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idTeamOperatore': idTeamOperatore, 'idOperatore': idOperatore, 'idRuoloOperativo': idRuoloOperativo, 'costoOrarioApplicato': costoOrarioApplicato, 'note': note, 'attivo': attivo}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio operatore team ${res.statusCode}: ${res.body}');
  }

  Future<List<CostoLineaProduzione>> getCostiLinea() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/costi-linea'));
    if (res.statusCode != 200) throw Exception('Errore costi linea ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => CostoLineaProduzione.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> salvaCostoLinea({int? idCostoLinea, required int idLinea, int? idMacchina, required DateTime validoDal, DateTime? validoAl, double? costoFissoOra, double? costoMacchinaOra, double? costoManodoperaOra, double? costoEnergiaOra, double? costoEnergiaUnita, String? note, bool attivo = true}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/costi-linea');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idCostoLinea': idCostoLinea, 'idLinea': idLinea, 'idMacchina': idMacchina, 'validoDal': validoDal.toIso8601String(), 'validoAl': validoAl?.toIso8601String(), 'costoFissoOra': costoFissoOra, 'costoMacchinaOra': costoMacchinaOra, 'costoManodoperaOra': costoManodoperaOra, 'costoEnergiaOra': costoEnergiaOra, 'costoEnergiaUnita': costoEnergiaUnita, 'note': note, 'attivo': attivo}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio costo linea ${res.statusCode}: ${res.body}');
  }


  Future<List<AttivitaProduttiva>> getAttivitaProduttive(DateTime dal, DateTime al) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/attivita').replace(queryParameters: {
      'dal': dal.toIso8601String(),
      'al': al.toIso8601String(),
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Errore agenda produzione ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => AttivitaProduttiva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AttivitaProduttiva> salvaAttivitaProduttiva({
    int? idAttivita,
    required int idVersione,
    required int idFase,
    required DateTime dataProduzione,
    required String stato,
    String? codArticolo,
    double? quantitaPrevista,
    int? idLinea,
    int? idMacchina,
    int? idTeam,
    DateTime? oraInizio,
    DateTime? oraFine,
    String? note,
  }) async {
    final res = await http.post(Uri.parse('${AppConfig.baseUrl}/api/attivita'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'idAttivita': idAttivita,
      'idVersione': idVersione,
      'idFase': idFase,
      'dataProduzione': dataProduzione.toIso8601String(),
      'stato': stato,
      'codArticolo': codArticolo,
      'quantitaPrevista': quantitaPrevista,
      'idLinea': idLinea,
      'idMacchina': idMacchina,
      'idTeam': idTeam,
      'oraInizio': oraInizio?.toIso8601String(),
      'oraFine': oraFine?.toIso8601String(),
      'note': note,
    }));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio attivita ${res.statusCode}: ${res.body}');
    return AttivitaProduttiva.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }  Future<List<ProcessoProduttivo>> getProcessi() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/processi'));
    if (res.statusCode != 200) throw Exception('Errore processi ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => ProcessoProduttivo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProcessoProduttivo> salvaProcesso({int? idProcesso, required String codProcesso, String? codArticolo, required String descrizione, String? note, String stato = 'BOZZA'}) async {
    final res = await http.post(Uri.parse('${AppConfig.baseUrl}/api/processi'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idProcesso': idProcesso, 'codProcesso': codProcesso, 'codArticolo': codArticolo, 'descrizione': descrizione, 'note': note, 'stato': stato}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio processo ${res.statusCode}: ${res.body}');
    return ProcessoProduttivo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<VersioneProcesso>> getVersioniProcesso(int idProcesso) async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/processi/$idProcesso/versioni'));
    if (res.statusCode != 200) throw Exception('Errore versioni processo ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => VersioneProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<VersioneProcesso>> salvaVersioneProcesso({required int idProcesso, int? idVersione, int? numeroVersione, String? descrizione, String? motivazione, required DateTime validoDal, DateTime? validoAl, String stato = 'BOZZA', double? tempoAttesoMinuti, double? setupAttesoMinuti, double? produttivitaAttesa, double? costoAtteso, double? energiaAttesa}) async {
    final res = await http.post(Uri.parse('${AppConfig.baseUrl}/api/processi/$idProcesso/versioni'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idVersione': idVersione, 'numeroVersione': numeroVersione, 'descrizione': descrizione, 'motivazione': motivazione, 'validoDal': validoDal.toIso8601String(), 'validoAl': validoAl?.toIso8601String(), 'stato': stato, 'tempoAttesoMinuti': tempoAttesoMinuti, 'setupAttesoMinuti': setupAttesoMinuti, 'produttivitaAttesa': produttivitaAttesa, 'costoAtteso': costoAtteso, 'energiaAttesa': energiaAttesa}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio versione ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => VersioneProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FaseProcesso>> getFasiProcesso(int idVersione) async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/processi/versioni/$idVersione/fasi'));
    if (res.statusCode != 200) throw Exception('Errore fasi processo ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => FaseProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FaseProcesso>> salvaFaseProcesso({required int idVersione, int? idFase, required int sequenza, required String codFase, required String descrizione, int? idLineaDefault, int? idMacchinaDefault, double? tempoStandardMinuti, double? setupStandardMinuti, double? produttivitaAttesa, double? costoStandard, double? energiaAttesa, double? qualitaAttesa, double? scartoAtteso, String? note, bool richiedeMacchina = true, bool richiedeTeam = true, bool richiedeSetup = false, bool richiedeOrari = true, bool richiedeArticolo = true, bool richiedeLotto = true, bool richiedeComponenti = true, bool richiedeControlloQualita = false, bool richiedeNote = false, bool generaErp = true, bool generaCaricoPf = true, bool generaScaricoComponenti = true}) async {
    final res = await http.post(Uri.parse('${AppConfig.baseUrl}/api/processi/versioni/$idVersione/fasi'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idFase': idFase, 'sequenza': sequenza, 'codFase': codFase, 'descrizione': descrizione, 'idLineaDefault': idLineaDefault, 'idMacchinaDefault': idMacchinaDefault, 'tempoStandardMinuti': tempoStandardMinuti, 'setupStandardMinuti': setupStandardMinuti, 'produttivitaAttesa': produttivitaAttesa, 'costoStandard': costoStandard, 'energiaAttesa': energiaAttesa, 'qualitaAttesa': qualitaAttesa, 'scartoAtteso': scartoAtteso, 'note': note, 'richiedeMacchina': richiedeMacchina, 'richiedeTeam': richiedeTeam, 'richiedeSetup': richiedeSetup, 'richiedeOrari': richiedeOrari, 'richiedeArticolo': richiedeArticolo, 'richiedeLotto': richiedeLotto, 'richiedeComponenti': richiedeComponenti, 'richiedeControlloQualita': richiedeControlloQualita, 'richiedeNote': richiedeNote, 'generaErp': generaErp, 'generaCaricoPf': generaCaricoPf, 'generaScaricoComponenti': generaScaricoComponenti}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio fase ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => FaseProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }  Future<List<FaseProcesso>> eliminaFaseProcesso({required int idVersione, required int idFase}) async {
    final res = await http.delete(Uri.parse('${AppConfig.baseUrl}/api/processi/versioni/$idVersione/fasi/$idFase'));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore eliminazione fase ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => FaseProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FaseRisorsaProcesso>> getFaseRisorse(int idFase) async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/api/processi/fasi/$idFase/risorse'));
    if (res.statusCode != 200) throw Exception('Errore risorse fase ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => FaseRisorsaProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FaseRisorsaProcesso>> salvaFaseRisorsa({required int idFase, int? idFaseRisorsa, int? idLinea, int? idMacchina, int? idTeam, required DateTime validoDal, DateTime? validoAl, double? velocitaReale, double? tempoSetupAggiuntivoMinuti, double? scartoMedio, double? energiaAggiuntiva, int? operatoriMinimi, int? operatoriConsigliati, String? competenzeRichieste, String? note}) async {
    final res = await http.post(Uri.parse('${AppConfig.baseUrl}/api/processi/fasi/$idFase/risorse'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idFaseRisorsa': idFaseRisorsa, 'idLinea': idLinea, 'idMacchina': idMacchina, 'idTeam': idTeam, 'validoDal': validoDal.toIso8601String(), 'validoAl': validoAl?.toIso8601String(), 'velocitaReale': velocitaReale, 'tempoSetupAggiuntivoMinuti': tempoSetupAggiuntivoMinuti, 'scartoMedio': scartoMedio, 'energiaAggiuntiva': energiaAggiuntiva, 'operatoriMinimi': operatoriMinimi, 'operatoriConsigliati': operatoriConsigliati, 'competenzeRichieste': competenzeRichieste, 'note': note}));
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Errore salvataggio risorsa fase ${res.statusCode}: ${res.body}');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => FaseRisorsaProcesso.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<List<ArticoloProduzione>> getArticoli() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/articoli');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore articoli ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return _dedupArticoli(
      data.map((e) => ArticoloProduzione.fromJson(e as Map<String, dynamic>)),
    );
  }

  Future<List<ArticoloProduzione>> getArticoliLinea(int idLinea) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/linee/$idLinea/articoli');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore articoli linea ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return _dedupArticoli(
      data.map((e) => ArticoloProduzione.fromJson(e as Map<String, dynamic>)),
    );
  }

  Future<DistintaProduzione> getDistinta(
    String codArticolo,
    double quantita,
  ) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/distinta').replace(
      queryParameters: {
        'codArticolo': codArticolo,
        'quantita': quantita.toString(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore distinta ${res.statusCode}: ${res.body}');
    }

    return DistintaProduzione.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<List<LottoProduzione>> getLotti(
    String codArticolo,
    String magazzino,
    DateTime dataProduzione,
  ) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/lotti').replace(
      queryParameters: {
        'codArticolo': codArticolo,
        'magazzino': magazzino,
        'dataProduzione': dataProduzione.toIso8601String(),
      },
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore lotti ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => LottoProduzione.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProduttivitaArticolo> getProduttivitaArticolo(String codArticolo, int? idLinea) async {
    final params = <String, String>{};
    if (idLinea != null) {
      params['idLinea'] = idLinea.toString();
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/articoli/$codArticolo/produttivita').replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore produttivita articolo ${res.statusCode}: ${res.body}');
    }

    return ProduttivitaArticolo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
  Future<List<DichiarazioneCalendarioGiorno>> getCalendarioDichiarazioni(DateTime dal, DateTime al) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni/calendario').replace(
      queryParameters: {
        'dal': dal.toIso8601String(),
        'al': al.toIso8601String(),
      },
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore calendario dichiarazioni ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => DichiarazioneCalendarioGiorno.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DichiarazioneStorico>> getDichiarazioni(DateTime dal, DateTime al) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni').replace(
      queryParameters: {
        'dal': dal.toIso8601String(),
        'al': al.toIso8601String(),
      },
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore dichiarazioni ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => DichiarazioneStorico.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DichiarazioneStorico> getDichiarazione(int idDichiarazione) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni/$idDichiarazione');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore dettaglio dichiarazione ${res.statusCode}: ${res.body}');
    }

    return DichiarazioneStorico.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> salvaDichiarazioneStorico(DichiarazioneStorico dichiarazione) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni/${dichiarazione.idDichiarazione}');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dichiarazione.toUpdateJson()),
    );

    if (res.statusCode != 204) {
      throw Exception('Errore salvataggio dichiarazione ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> annullaDichiarazioneStorico(int idDichiarazione) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni/$idDichiarazione');
    final res = await http.delete(uri);

    if (res.statusCode != 204) {
      throw Exception('Errore annullamento dichiarazione ${res.statusCode}: ${res.body}');
    }
  }
  Future<String> confermaDichiarazionePrevista(int idDichiarazione) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazioni/$idDichiarazione/conferma');
    final res = await http.post(uri);

    if (res.statusCode != 200) {
      throw Exception('Errore conferma previsione ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['messaggio']?.toString() ?? 'Dichiarazione prevista confermata.';
  }

  Future<List<ChiusuraFase>> getChiusureFase({int? idAttivita, int? idFase}) async {
    final params = <String, String>{};
    if (idAttivita != null) params['idAttivita'] = idAttivita.toString();
    if (idFase != null) params['idFase'] = idFase.toString();
    final uri = Uri.parse('${AppConfig.baseUrl}/api/chiusure-fase').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Errore lettura chiusure fase ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => ChiusuraFase.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<String> confermaChiusuraFase({
    int? idChiusuraFase,
    int? idAttivita,
    required int idFase,
    int? idLinea,
    int? idMacchina,
    int? idTeam,
    String? articoloProdotto,
    String? descrizioneProdotto,
    double? quantita,
    required DateTime dataProduzione,
    DateTime? oraInizio,
    DateTime? oraFine,
    String? lottoProdotto,
    String? magazzinoProdotto,
    required List<ComponenteDistinta> componenti,
    required List<DichiarazioneOperatore> operatori,
    String? note,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/chiusure-fase');
    final body = {
      'idChiusuraFase': idChiusuraFase,
      'idAttivita': idAttivita,
      'idFase': idFase,
      'idLinea': idLinea,
      'idMacchina': idMacchina,
      'idTeam': idTeam,
      'codAzi': AppConfig.codAzi,
      'esercizio': AppConfig.esercizio,
      'dataChiusura': dataProduzione.toIso8601String(),
      'dataProduzione': dataProduzione.toIso8601String(),
      'oraInizio': oraInizio?.toIso8601String(),
      'oraFine': oraFine?.toIso8601String(),
      'articoloProdotto': articoloProdotto,
      'descrizioneProdotto': descrizioneProdotto,
      'lottoProdotto': lottoProdotto,
      'magazzinoProdotto': magazzinoProdotto,
      'codArticolo': articoloProdotto,
      'descrizioneArticolo': descrizioneProdotto,
      'lotto': lottoProdotto,
      'magazzino': magazzinoProdotto,
      'quantita': quantita,
      'componenti': componenti.map((e) => e.toJson()).toList(),
      'operatori': operatori.map((e) => e.toJson()).toList(),
      'note': note,
    };

    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode != 200) {
      throw Exception('Errore chiusura fase ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['messaggio']?.toString() ?? 'Chiusura fase registrata.';
  }
  Future<String> confermaDichiarazione({
    required int? idLinea,
    required int? idMacchina,
    required String articoloProdotto,
    required String descrizioneProdotto,
    required double quantitaProdotta,
    required DateTime dataProduzione,
    required DateTime oraInizioProduzione,
    required DateTime oraFineProduzione,
    required String lottoProdotto,
    required String magazzinoProdotto,
    required List<ComponenteDistinta> componenti,
    required List<DichiarazioneOperatore> operatori,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/produzione/dichiarazione');
    final body = {
      'idLinea': idLinea,
      'idMacchina': idMacchina,
      'codAzi': AppConfig.codAzi,
      'esercizio': AppConfig.esercizio,
      'dataProduzione': dataProduzione.toIso8601String(),
      'oraInizioProduzione': oraInizioProduzione.toIso8601String(),
      'oraFineProduzione': oraFineProduzione.toIso8601String(),
      'articoloProdotto': articoloProdotto,
      'descrizioneProdotto': descrizioneProdotto,
      'lottoProdotto': lottoProdotto,
      'magazzinoProdotto': magazzinoProdotto,
      'quantitaProdotta': quantitaProdotta,
      'componenti': componenti.map((e) => e.toJson()).toList(),
      'operatori': operatori.map((e) => e.toJson()).toList(),
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Errore conferma ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['messaggio']?.toString() ?? 'Dichiarazione confermata.';
  }

  List<ArticoloProduzione> _dedupArticoli(Iterable<ArticoloProduzione> articoli) {
    final byCode = <String, ArticoloProduzione>{};
    for (final articolo in articoli) {
      byCode.putIfAbsent(articolo.codArticolo, () => articolo);
    }
    return byCode.values.toList();
  }
}
class ConfigurazioneAttiva {
  final int idConfig;
  final String codAziAdhoc;
  final String prefissoAzienda;
  final String causaleCarico;
  final String causaleScarico;
  final String magazzinoPFDefault;
  final String magazzinoComponentiDefault;

  const ConfigurazioneAttiva({
    required this.idConfig,
    required this.codAziAdhoc,
    required this.prefissoAzienda,
    required this.causaleCarico,
    required this.causaleScarico,
    required this.magazzinoPFDefault,
    required this.magazzinoComponentiDefault,
  });

  factory ConfigurazioneAttiva.fromJson(Map<String, dynamic> json) {
    return ConfigurazioneAttiva(
      idConfig: int.tryParse(json['idConfig']?.toString() ?? '') ?? 0,
      codAziAdhoc: json['codAziAdhoc']?.toString() ?? '',
      prefissoAzienda: json['prefissoAzienda']?.toString() ?? '',
      causaleCarico: json['causaleCarico']?.toString() ?? '',
      causaleScarico: json['causaleScarico']?.toString() ?? '',
      magazzinoPFDefault: json['magazzinoPFDefault']?.toString() ?? '',
      magazzinoComponentiDefault: json['magazzinoComponentiDefault']?.toString() ?? '',
    );
  }
}


































