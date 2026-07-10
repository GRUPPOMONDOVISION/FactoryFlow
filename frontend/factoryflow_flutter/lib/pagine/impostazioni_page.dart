// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class ImpostazioniPage extends StatefulWidget {
  const ImpostazioniPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ImpostazioniPage> createState() => _ImpostazioniPageState();
}

class _ImpostazioniPageState extends State<ImpostazioniPage> {
  final _service = ProduzioneService();
  ConfigurazioneAttiva? _config;
  List<LineaProduzione> _linee = [];
  List<OperatoreProduzione> _operatori = [];
  List<RuoloOperativo> _ruoli = [];
  List<MacchinaProduzione> _macchine = [];
  List<SetupTipoProduzione> _setupTipi = [];
  List<SetupRegolaProduzione> _setupRegole = [];
  List<TeamOperativo> _team = [];
  List<TeamOperatore> _teamOperatori = [];
  List<CostoLineaProduzione> _costiLinea = [];
  bool _loading = true;

  final _opCod = TextEditingController();
  final _opNome = TextEditingController();
  final _opCognome = TextEditingController();
  final _opCosto = TextEditingController();
  final _opMotivoObsolescenza = TextEditingController();
  final _ruoloCod = TextEditingController();
  final _ruoloDesc = TextEditingController();
  final _teamCod = TextEditingController();
  final _teamDesc = TextEditingController();
  final _teamNote = TextEditingController();
  final _teamCosto = TextEditingController();
  final _teamOpNote = TextEditingController();
  final _macCod = TextEditingController();
  final _macNome = TextEditingController();
  final _macDesc = TextEditingController();
  final _macKwSpunto = TextEditingController();
  final _macKwFunzione = TextEditingController();
  final _macBenchmark = TextEditingController();
  final _macNoteTecniche = TextEditingController();
  final _setupCod = TextEditingController();
  final _setupDesc = TextEditingController();
  final _regArticolo = TextEditingController();
  final _regTempo = TextEditingController();
  final _regCosto = TextEditingController();
  final _costoFisso = TextEditingController();
  final _costoMacchina = TextEditingController();
  final _costoManodopera = TextEditingController();
  final _costoEnergiaOra = TextEditingController();
  final _costoEnergiaUnita = TextEditingController();
  final _costoNote = TextEditingController();

  int? _selectedOperatoreId;
  int? _macLinea;
  int? _regSetupTipo;
  int? _regLinea;
  int? _regMacchina;
  int? _teamSelezionato;
  int? _teamOperatore;
  int? _teamRuolo;
  int? _costoLinea;
  int? _costoMacchinaId;
  int? _selectedSetupTipoId;
  int? _selectedSetupRegolaId;
  int? _selectedRuoloId;
  int? _selectedMacchinaId;
  int? _selectedTeamOperatoreId;
  DateTime _costoValidoDal = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_opCod, _opNome, _opCognome, _opCosto, _opMotivoObsolescenza, _ruoloCod, _ruoloDesc, _teamCod, _teamDesc, _teamNote, _teamCosto, _teamOpNote, _macCod, _macNome, _macDesc, _macKwSpunto, _macKwFunzione, _macBenchmark, _macNoteTecniche, _setupCod, _setupDesc, _regArticolo, _regTempo, _regCosto, _costoFisso, _costoMacchina, _costoManodopera, _costoEnergiaOra, _costoEnergiaUnita, _costoNote]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getConfigurazioneAttiva(),
        _service.getLinee(soloAttive: false),
        _service.getOperatori(soloAttivi: false),
        _service.getRuoliOperativi(),
        _service.getMacchine(),
        _service.getSetupTipi(),
        _service.getSetupRegole(),
        _service.getTeamOperativi(),
        _service.getCostiLinea(),
      ]);
      final teamList = results[7] as List<TeamOperativo>;
      final selectedTeam = _teamSelezionato ?? (teamList.isEmpty ? null : teamList.first.idTeam);
      final teamOps = selectedTeam == null ? <TeamOperatore>[] : await _service.getTeamOperatori(selectedTeam);
      if (!mounted) return;
      setState(() {
        _config = results[0] as ConfigurazioneAttiva;
        _linee = results[1] as List<LineaProduzione>;
        _operatori = results[2] as List<OperatoreProduzione>;
        _ruoli = results[3] as List<RuoloOperativo>;
        _macchine = results[4] as List<MacchinaProduzione>;
        _setupTipi = results[5] as List<SetupTipoProduzione>;
        _setupRegole = results[6] as List<SetupRegolaProduzione>;
        _team = teamList;
        _teamSelezionato = selectedTeam;
        _teamOperatori = teamOps;
        _costiLinea = results[8] as List<CostoLineaProduzione>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Errore caricamento impostazioni: $e', error: true);
    }
  }

  Future<void> _loadTeamOperatori(int? idTeam) async {
    if (idTeam == null) {
      setState(() => _teamOperatori = []);
      return;
    }
    final rows = await _service.getTeamOperatori(idTeam);
    if (!mounted) return;
    setState(() {
      _teamSelezionato = idTeam;
      _teamOperatori = rows;
    });
  }



  void _newOperatore() {
    setState(() {
      _selectedOperatoreId = null;
      _opCod.clear();
      _opNome.clear();
      _opCognome.clear();
      _opCosto.clear();
      _opMotivoObsolescenza.clear();
    });
  }

  void _selectOperatore(OperatoreProduzione operatore) {
    setState(() {
      _selectedOperatoreId = operatore.idOperatore;
      _opCod.text = operatore.codOperatore;
      _opNome.text = operatore.nome;
      _opCognome.text = operatore.cognome ?? '';
      _opCosto.text = operatore.costoOrarioRiferimento == null ? '' : operatore.costoOrarioRiferimento!.toString();
      _opMotivoObsolescenza.text = operatore.motivoObsolescenza ?? '';
    });
  }

  void _newMacchina() {
    setState(() {
      _selectedMacchinaId = null;
      _macLinea = null;
      _macCod.clear();
      _macNome.clear();
      _macDesc.clear();
      _macKwSpunto.clear();
      _macKwFunzione.clear();
      _macBenchmark.clear();
      _macNoteTecniche.clear();
    });
  }

  void _selectMacchina(MacchinaProduzione macchina) {
    setState(() {
      _selectedMacchinaId = macchina.idMacchina;
      _macLinea = macchina.idLinea;
      _macCod.text = macchina.codMacchina;
      _macNome.text = macchina.nomeMacchina;
      _macDesc.text = macchina.descrizione ?? '';
      _macKwSpunto.text = macchina.consumoKwSpunto == null ? '' : macchina.consumoKwSpunto!.toString();
      _macKwFunzione.text = macchina.consumoKwFunzione == null ? '' : macchina.consumoKwFunzione!.toString();
      _macBenchmark.text = macchina.unitaMinutoBenchmark == null ? '' : macchina.unitaMinutoBenchmark!.toString();
      _macNoteTecniche.text = macchina.noteTecniche ?? '';
    });
  }
  void _newRuolo() {
    setState(() {
      _selectedRuoloId = null;
      _ruoloCod.clear();
      _ruoloDesc.clear();
    });
  }

  void _selectRuolo(RuoloOperativo ruolo) {
    setState(() {
      _selectedRuoloId = ruolo.idRuoloOperativo;
      _ruoloCod.text = ruolo.codRuolo;
      _ruoloDesc.text = ruolo.descrizione;
    });
  }
  void _newTeam() {
    setState(() {
      _teamSelezionato = null;
      _selectedTeamOperatoreId = null;
      _teamCod.clear();
      _teamDesc.clear();
      _teamNote.clear();
      _teamOperatore = null;
      _teamRuolo = null;
      _teamCosto.clear();
      _teamOpNote.clear();
      _teamOperatori = [];
    });
  }

  Future<void> _selectTeam(TeamOperativo team) async {
    setState(() {
      _teamSelezionato = team.idTeam;
      _selectedTeamOperatoreId = null;
      _teamCod.text = team.codTeam;
      _teamDesc.text = team.descrizione;
      _teamNote.text = team.note ?? '';
      _teamOperatore = null;
      _teamRuolo = null;
      _teamCosto.clear();
      _teamOpNote.clear();
    });
    await _loadTeamOperatori(team.idTeam);
  }

  void _selectTeamOperatore(TeamOperatore row) {
    setState(() {
      _selectedTeamOperatoreId = row.idTeamOperatore;
      _teamOperatore = row.idOperatore;
      _teamRuolo = row.idRuoloOperativo;
      _teamCosto.text = row.costoOrarioApplicato == null ? '' : row.costoOrarioApplicato!.toString();
      _teamOpNote.text = row.note ?? '';
    });
  }

  void _newSetupTipo() {
    setState(() {
      _selectedSetupTipoId = null;
      _selectedSetupRegolaId = null;
      _setupCod.clear();
      _setupDesc.clear();
      _regSetupTipo = null;
      _regLinea = null;
      _regMacchina = null;
      _regArticolo.clear();
      _regTempo.clear();
      _regCosto.clear();
    });
  }

  void _selectSetupTipo(SetupTipoProduzione tipo) {
    setState(() {
      _selectedSetupTipoId = tipo.idSetupTipo;
      _selectedSetupRegolaId = null;
      _setupCod.text = tipo.codSetupTipo;
      _setupDesc.text = tipo.descrizione;
      _regSetupTipo = tipo.idSetupTipo;
      _regLinea = null;
      _regMacchina = null;
      _regArticolo.clear();
      _regTempo.clear();
      _regCosto.clear();
    });
  }

  void _newSetupRegola() {
    setState(() {
      _selectedSetupRegolaId = null;
      _regSetupTipo = _selectedSetupTipoId;
      _regLinea = null;
      _regMacchina = null;
      _regArticolo.clear();
      _regTempo.clear();
      _regCosto.clear();
    });
  }

  void _selectSetupRegola(SetupRegolaProduzione regola) {
    setState(() {
      _selectedSetupRegolaId = regola.idSetupRegola;
      _regSetupTipo = regola.idSetupTipo;
      _regLinea = regola.idLinea;
      _regMacchina = regola.idMacchina;
      _regArticolo.text = regola.codArticolo ?? '';
      _regTempo.text = regola.tempoStandardMinuti == null ? '' : regola.tempoStandardMinuti!.toString();
      _regCosto.text = regola.costoStandard == null ? '' : regola.costoStandard!.toString();
    });
  }

  Future<void> _saveOperatore() async {
    await _service.salvaOperatore(idOperatore: _selectedOperatoreId, codOperatore: _opCod.text.trim(), nome: _opNome.text.trim(), cognome: _opCognome.text.trim(), costoOrarioRiferimento: _num(_opCosto.text));
    _newOperatore();
    await _load();
    _message('Operatore salvato.');
  }

  Future<void> _saveRuolo() async {
    await _service.salvaRuoloOperativo(idRuoloOperativo: _selectedRuoloId, codRuolo: _ruoloCod.text.trim(), descrizione: _ruoloDesc.text.trim());
    _newRuolo();
    await _load();
    _message('Ruolo operativo salvato.');
  }

  Future<void> _saveTeam() async {
    await _service.salvaTeamOperativo(idTeam: _teamSelezionato, codTeam: _teamCod.text.trim(), descrizione: _teamDesc.text.trim(), note: _teamNote.text.trim());
    _teamCod.clear(); _teamDesc.clear(); _teamNote.clear(); _teamSelezionato = null;
    await _load();
    _message('Team operativo salvato.');
  }

  Future<void> _saveTeamOperatore() async {
    if (_teamSelezionato == null || _teamOperatore == null) {
      _message('Selezionare team e operatore.', error: true);
      return;
    }
    final duplicatoAperto = _teamOperatori.any((o) => o.attivo && o.idOperatore == _teamOperatore && o.idTeamOperatore != _selectedTeamOperatoreId);
    if (duplicatoAperto) {
      _message('Operatore gia presente nel team con validita aperta.', error: true);
      return;
    }
    await _service.salvaTeamOperatore(idTeamOperatore: _selectedTeamOperatoreId, idTeam: _teamSelezionato!, idOperatore: _teamOperatore!, idRuoloOperativo: _teamRuolo, costoOrarioApplicato: _num(_teamCosto.text), note: _teamOpNote.text.trim());
    _selectedTeamOperatoreId = null; _teamOperatore = null; _teamRuolo = null; _teamCosto.clear(); _teamOpNote.clear();
    await _loadTeamOperatori(_teamSelezionato);
    _message('Operatore aggiunto al team.');
  }

  Future<void> _saveMacchina() async {
    await _service.salvaMacchina(idMacchina: _selectedMacchinaId, idLinea: _macLinea, codMacchina: _macCod.text.trim(), nomeMacchina: _macNome.text.trim(), descrizione: _macDesc.text.trim(), consumoKwSpunto: _num(_macKwSpunto.text), consumoKwFunzione: _num(_macKwFunzione.text), unitaMinutoBenchmark: _num(_macBenchmark.text), noteTecniche: _macNoteTecniche.text.trim());
    _newMacchina();
    await _load();
    _message('Macchina salvata.');
  }

  Future<void> _saveSetupTipo() async {
    await _service.salvaSetupTipo(idSetupTipo: _selectedSetupTipoId, codSetupTipo: _setupCod.text.trim(), descrizione: _setupDesc.text.trim());
    _selectedSetupTipoId = null; _setupCod.clear(); _setupDesc.clear();
    await _load();
    _message('Tipo setup salvato.');
  }

  Future<void> _saveSetupRegola() async {
    if (_regSetupTipo == null) {
      _message('Selezionare un tipo setup.', error: true);
      return;
    }
    await _service.salvaSetupRegola(idSetupRegola: _selectedSetupRegolaId, idSetupTipo: _regSetupTipo!, idLinea: _regLinea, idMacchina: _regMacchina, codArticolo: _regArticolo.text.trim(), tempoStandardMinuti: _num(_regTempo.text), costoStandard: _num(_regCosto.text));
    _selectedSetupRegolaId = null; _regArticolo.clear(); _regTempo.clear(); _regCosto.clear(); _regSetupTipo = _selectedSetupTipoId; _regLinea = null; _regMacchina = null;
    await _load();
    _message('Regola setup salvata.');
  }

  Future<void> _saveCostoLinea() async {
    if (_costoLinea == null) {
      _message('Selezionare una linea.', error: true);
      return;
    }
    await _service.salvaCostoLinea(idLinea: _costoLinea!, idMacchina: _costoMacchinaId, validoDal: _costoValidoDal, costoFissoOra: _num(_costoFisso.text), costoMacchinaOra: _num(_costoMacchina.text), costoManodoperaOra: _num(_costoManodopera.text), costoEnergiaOra: _num(_costoEnergiaOra.text), costoEnergiaUnita: _num(_costoEnergiaUnita.text), note: _costoNote.text.trim());
    _costoFisso.clear(); _costoMacchina.clear(); _costoManodopera.clear(); _costoEnergiaOra.clear(); _costoEnergiaUnita.clear(); _costoNote.clear();
    await _load();
    _message('Costo linea salvato.');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      initialIndex: widget.initialTab.clamp(0, 5),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FactoryFlow - Impostazioni'),
          actions: [IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh), tooltip: 'Aggiorna')],
          bottom: const TabBar(isScrollable: true, tabs: [Tab(text: 'Config'), Tab(text: 'Operatori'), Tab(text: 'Team'), Tab(text: 'Macchine'), Tab(text: 'Setup'), Tab(text: 'Costi macchina')]),
        ),
        body: _loading ? const Center(child: CircularProgressIndicator()) : TabBarView(children: [_configTab(), _operatoriTab(), _teamTab(), _macchineTab(), _setupTab(), _costiTab()]),
      ),
    );
  }

  Widget _configTab() {
    final c = _config;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _section('Configurazione attiva', [
        _tile('Azienda AdHoc', c?.codAziAdhoc ?? '-'),
        _tile('Prefisso', c?.prefissoAzienda ?? '-'),
        _tile('Causale carico', c?.causaleCarico ?? '-'),
        _tile('Causale scarico', c?.causaleScarico ?? '-'),
        _tile('Magazzino PF', c?.magazzinoPFDefault ?? '-'),
        _tile('Magazzino componenti', c?.magazzinoComponentiDefault ?? '-'),
      ]),
    ]);
  }

  Widget _operatoriTab() {
    final operatoriAttivi = _operatori.where((o) => o.attivo).toList();
    final operatoriObsoleti = _operatori.where((o) => !o.attivo).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _hint('Operatori e ruoli sono due anagrafiche distinte. Gli operatori obsoleti restano nello storico ma non vengono proposti nelle nuove dichiarazioni.'),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final operatoriPanel = _panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text('Operatori', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _newOperatore, icon: const Icon(Icons.add), tooltip: 'Nuovo operatore')]),
          const SizedBox(height: 8),
          _form(_selectedOperatoreId == null ? 'Nuovo operatore' : 'Modifica operatore', [
            _field(_opCod, 'Codice'),
            _field(_opNome, 'Nome'),
            _field(_opCognome, 'Cognome'),
            _field(_opCosto, 'Costo/h riferimento', number: true),
            _field(_opMotivoObsolescenza, 'Motivo obsolescenza'),
            FilledButton.icon(onPressed: _saveOperatore, icon: const Icon(Icons.save_outlined), label: const Text('Salva operatore')),
            if (_selectedOperatoreId != null) OutlinedButton.icon(onPressed: () async { await _service.salvaOperatore(idOperatore: _selectedOperatoreId, codOperatore: _opCod.text.trim(), nome: _opNome.text.trim(), cognome: _opCognome.text.trim(), costoOrarioRiferimento: _num(_opCosto.text), attivo: false, dataObsolescenza: DateTime.now(), motivoObsolescenza: _opMotivoObsolescenza.text.trim()); _newOperatore(); await _load(); _message('Operatore reso obsoleto per usi futuri.'); }, icon: const Icon(Icons.block_outlined), label: const Text('Rendi obsoleto')),
          ]),
          const SizedBox(height: 12),
          _section('Operatori attivi', operatoriAttivi.map((o) => _selectableTile(label: o.label, value: o.costoOrarioRiferimento == null ? 'Costo/h -' : 'Costo/h ${_fmt(o.costoOrarioRiferimento!)}', selected: _selectedOperatoreId == o.idOperatore, onTap: () => _selectOperatore(o))).toList()),
          if (operatoriObsoleti.isNotEmpty) ExpansionTile(title: Text('Operatori obsoleti (${operatoriObsoleti.length})'), children: operatoriObsoleti.map((o) => _selectableTile(label: o.label, value: 'Obsoleto dal ${o.dataObsolescenza == null ? '-' : _date(o.dataObsolescenza!)}', selected: _selectedOperatoreId == o.idOperatore, onTap: () => _selectOperatore(o))).toList()),
        ]));
        final ruoliPanel = _panel(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text('Ruoli operativi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _newRuolo, icon: const Icon(Icons.add), tooltip: 'Nuovo ruolo')]),
          const SizedBox(height: 8),
          _form(_selectedRuoloId == null ? 'Nuovo ruolo operativo' : 'Modifica ruolo operativo', [_field(_ruoloCod, 'Codice ruolo'), _field(_ruoloDesc, 'Descrizione'), FilledButton.icon(onPressed: _saveRuolo, icon: const Icon(Icons.save_outlined), label: const Text('Salva ruolo')), if (_selectedRuoloId != null) OutlinedButton.icon(onPressed: () async { await _service.salvaRuoloOperativo(idRuoloOperativo: _selectedRuoloId, codRuolo: _ruoloCod.text.trim(), descrizione: _ruoloDesc.text.trim(), attivo: false); _newRuolo(); await _load(); _message('Ruolo disattivato per usi futuri.'); }, icon: const Icon(Icons.block_outlined), label: const Text('Disattiva ruolo'))]),
          const SizedBox(height: 12),
          _section('Elenco ruoli', _ruoli.map((r) => _selectableTile(label: r.codRuolo, value: r.descrizione, selected: _selectedRuoloId == r.idRuoloOperativo, onTap: () => _selectRuolo(r))).toList()),
        ]));
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: operatoriPanel), const SizedBox(width: 12), Expanded(child: ruoliPanel)]) : Column(children: [operatoriPanel, const SizedBox(height: 12), ruoliPanel]);
      }),
    ]);
  }

  Widget _teamTab() {
    final operatoriAttivi = _teamOperatori.where((o) => o.attivo).toList();
    final operatoriStorici = _teamOperatori.where((o) => !o.attivo).toList();
    TeamOperatore? selectedTeamOperatore;
    for (final row in _teamOperatori) {
      if (row.idTeamOperatore == _selectedTeamOperatoreId) {
        selectedTeamOperatore = row;
        break;
      }
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      _hint('Un team operativo e un master: salvalo insieme alla sua composizione. Se scegli un team esistente puoi modificarne descrizione, note e operatori senza creare duplicati.'),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final master = _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('Team operativi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _newTeam, icon: const Icon(Icons.add), tooltip: 'Nuovo team')]),
          const SizedBox(height: 8),
          if (_team.isEmpty) const Text('Nessun team configurato.') else ..._team.map((t) => _selectableTile(label: t.label, value: t.note ?? 'Attivo', selected: _teamSelezionato == t.idTeam, onTap: () => _selectTeam(t))),
        ]));
        final detail = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _form(_teamSelezionato == null ? 'Nuovo team operativo' : 'Modifica team operativo', [
            _field(_teamCod, 'Codice team'),
            _field(_teamDesc, 'Descrizione team'),
            _field(_teamNote, 'Note'),
            FilledButton.icon(onPressed: _saveTeam, icon: const Icon(Icons.save_outlined), label: const Text('Salva team')),
            if (_teamSelezionato != null) OutlinedButton.icon(onPressed: _teamOperatori.any((o) => o.attivo) ? null : () async { await _service.salvaTeamOperativo(idTeam: _teamSelezionato, codTeam: _teamCod.text.trim(), descrizione: _teamDesc.text.trim(), note: _teamNote.text.trim(), attivo: false); _newTeam(); await _load(); }, icon: const Icon(Icons.block_outlined), label: const Text('Disattiva team')),
          ]),
          const SizedBox(height: 12),
          _form(_selectedTeamOperatoreId == null ? 'Aggiungi operatore al team' : 'Modifica operatore del team', [
            _dropdown<int?>(label: 'Operatore', value: _teamOperatore, items: _operatori.map((o) => DropdownMenuItem<int?>(value: o.idOperatore, child: Text(o.label))).toList(), onChanged: (v) => setState(() => _teamOperatore = v)),
            _dropdown<int?>(label: 'Ruolo nel team', value: _teamRuolo, items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessun ruolo')), ..._ruoli.map((r) => DropdownMenuItem<int?>(value: r.idRuoloOperativo, child: Text(r.label)))], onChanged: (v) => setState(() => _teamRuolo = v)),
            _field(_teamCosto, 'Costo/h applicato', number: true),
            _field(_teamOpNote, 'Note'),
            FilledButton.icon(onPressed: _teamSelezionato == null ? null : _saveTeamOperatore, icon: const Icon(Icons.person_add_alt_1_outlined), label: Text(_selectedTeamOperatoreId == null ? 'Aggiungi al team' : 'Salva operatore')),
            if (_selectedTeamOperatoreId != null && (selectedTeamOperatore?.attivo ?? false)) OutlinedButton.icon(onPressed: () async { await _service.salvaTeamOperatore(idTeamOperatore: _selectedTeamOperatoreId, idTeam: _teamSelezionato!, idOperatore: _teamOperatore!, idRuoloOperativo: _teamRuolo, costoOrarioApplicato: _num(_teamCosto.text), note: _teamOpNote.text.trim(), attivo: false); _selectedTeamOperatoreId = null; _teamOperatore = null; _teamRuolo = null; _teamCosto.clear(); _teamOpNote.clear(); await _loadTeamOperatori(_teamSelezionato); _message('Validita operatore chiusa. La riga resta nello storico.'); }, icon: const Icon(Icons.block_outlined), label: const Text('Chiudi validita')),
          ]),
          const SizedBox(height: 12),
          _section('Operatori attivi', operatoriAttivi.isEmpty ? [const Text('Nessun operatore attivo nel team.')] : operatoriAttivi.map((o) => _selectableTile(label: o.nomeCompleto, value: 'Costo/h ${o.costoOrarioApplicato == null ? "-" : _fmt(o.costoOrarioApplicato!)} - Dal ${o.validoDal == null ? "-" : _date(o.validoDal!)}', selected: _selectedTeamOperatoreId == o.idTeamOperatore, onTap: () => _selectTeamOperatore(o))).toList()),
          if (operatoriStorici.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Storico composizione team (${operatoriStorici.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              children: operatoriStorici.map((o) => _selectableTile(label: o.nomeCompleto, value: 'Dal ${o.validoDal == null ? "-" : _date(o.validoDal!)} al ${o.validoAl == null ? "-" : _date(o.validoAl!)} - Costo/h ${o.costoOrarioApplicato == null ? "-" : _fmt(o.costoOrarioApplicato!)}', selected: _selectedTeamOperatoreId == o.idTeamOperatore, onTap: () => _selectTeamOperatore(o))).toList(),
            ),
          ],
        ]);
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 360, child: master), const SizedBox(width: 12), Expanded(child: detail)]) : Column(children: [master, const SizedBox(height: 12), detail]);
      }),
    ]);
  }

  Widget _macchineTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _hint('Le caratteristiche tecniche della macchina sono dati MES: servono per benchmark produttivi, consumi e analisi industriale.'),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final master = _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('Macchine / risorse', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _newMacchina, icon: const Icon(Icons.add), tooltip: 'Nuova macchina')]),
          const SizedBox(height: 8),
          if (_macchine.isEmpty) const Text('Nessuna macchina configurata.') else ..._macchine.map((m) => _selectableTile(label: m.label, value: '${m.codLinea == null ? 'Linea -' : 'Linea ${m.codLinea}'} - Benchmark ${m.unitaMinutoBenchmark == null ? '-' : _fmt(m.unitaMinutoBenchmark!)} u/min', selected: _selectedMacchinaId == m.idMacchina, onTap: () => _selectMacchina(m))),
        ]));
        final detail = _form(_selectedMacchinaId == null ? 'Nuova macchina / risorsa' : 'Modifica macchina / risorsa', [
          _dropdown<int?>(label: 'Linea', value: _macLinea, items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna linea')), ..._linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label)))], onChanged: (v) => setState(() => _macLinea = v)),
          _field(_macCod, 'Codice macchina'),
          _field(_macNome, 'Nome macchina'),
          _field(_macDesc, 'Descrizione'),
          _field(_macKwSpunto, 'Consumo kW allo spunto', number: true),
          _field(_macKwFunzione, 'Consumo kW in funzione', number: true),
          _field(_macBenchmark, 'Benchmark unita/minuto', number: true),
          _field(_macNoteTecniche, 'Note tecniche'),
          FilledButton.icon(onPressed: _saveMacchina, icon: const Icon(Icons.save_outlined), label: const Text('Salva macchina')),
          if (_selectedMacchinaId != null) OutlinedButton.icon(onPressed: () async { await _service.salvaMacchina(idMacchina: _selectedMacchinaId, idLinea: _macLinea, codMacchina: _macCod.text.trim(), nomeMacchina: _macNome.text.trim(), descrizione: _macDesc.text.trim(), consumoKwSpunto: _num(_macKwSpunto.text), consumoKwFunzione: _num(_macKwFunzione.text), unitaMinutoBenchmark: _num(_macBenchmark.text), noteTecniche: _macNoteTecniche.text.trim(), attiva: false); _newMacchina(); await _load(); _message('Macchina disattivata per usi futuri.'); }, icon: const Icon(Icons.block_outlined), label: const Text('Disattiva macchina')),
        ]);
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 420, child: master), const SizedBox(width: 12), Expanded(child: detail)]) : Column(children: [master, const SizedBox(height: 12), detail]);
      }),
    ]);
  }

  Widget _setupTab() {
    final regoleMaster = _selectedSetupTipoId == null ? _setupRegole : _setupRegole.where((r) => r.idSetupTipo == _selectedSetupTipoId).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _hint('Il tipo setup e il master. Le regole sono il dettaglio: crea o modifica il master e poi completa le regole operative necessarie.'),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final master = _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text('Tipi setup', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _newSetupTipo, icon: const Icon(Icons.add), tooltip: 'Nuovo tipo setup')]),
          const SizedBox(height: 8),
          if (_setupTipi.isEmpty) const Text('Nessun tipo setup configurato.') else ..._setupTipi.map((s) => _selectableTile(label: s.label, value: s.attivo ? 'Attivo' : 'Disattivato', selected: _selectedSetupTipoId == s.idSetupTipo, onTap: () => _selectSetupTipo(s))),
        ]));
        final detail = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _form(_selectedSetupTipoId == null ? 'Nuovo tipo setup' : 'Modifica tipo setup', [
            _field(_setupCod, 'Codice setup'),
            _field(_setupDesc, 'Descrizione'),
            FilledButton.icon(onPressed: _saveSetupTipo, icon: const Icon(Icons.save_outlined), label: const Text('Salva tipo setup')),
            if (_selectedSetupTipoId != null) OutlinedButton.icon(onPressed: regoleMaster.any((r) => r.attiva) ? null : () async { await _service.salvaSetupTipo(idSetupTipo: _selectedSetupTipoId, codSetupTipo: _setupCod.text.trim(), descrizione: _setupDesc.text.trim(), attivo: false); _newSetupTipo(); await _load(); }, icon: const Icon(Icons.block_outlined), label: const Text('Disattiva tipo')),
          ]),
          const SizedBox(height: 12),
          _form(_selectedSetupRegolaId == null ? 'Nuova regola setup' : 'Modifica regola setup', [
            _dropdown<int?>(label: 'Tipo setup', value: _regSetupTipo, items: _setupTipi.map((s) => DropdownMenuItem<int?>(value: s.idSetupTipo, child: Text(s.label))).toList(), onChanged: (v) => setState(() => _regSetupTipo = v)),
            _dropdown<int?>(label: 'Linea', value: _regLinea, items: [const DropdownMenuItem<int?>(value: null, child: Text('Qualsiasi linea')), ..._linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label)))], onChanged: (v) => setState(() => _regLinea = v)),
            _dropdown<int?>(label: 'Macchina', value: _regMacchina, items: [const DropdownMenuItem<int?>(value: null, child: Text('Qualsiasi macchina')), ..._macchine.map((m) => DropdownMenuItem<int?>(value: m.idMacchina, child: Text(m.label)))], onChanged: (v) => setState(() => _regMacchina = v)),
            _field(_regArticolo, 'Articolo specifico'),
            _field(_regTempo, 'Tempo standard minuti', number: true),
            _field(_regCosto, 'Costo setup standard', number: true),
            FilledButton.icon(onPressed: _saveSetupRegola, icon: const Icon(Icons.save_outlined), label: Text(_selectedSetupRegolaId == null ? 'Aggiungi regola' : 'Salva regola')),
            if (_selectedSetupRegolaId != null) OutlinedButton.icon(onPressed: () async { await _service.salvaSetupRegola(idSetupRegola: _selectedSetupRegolaId, idSetupTipo: _regSetupTipo!, idLinea: _regLinea, idMacchina: _regMacchina, codArticolo: _regArticolo.text.trim(), tempoStandardMinuti: _num(_regTempo.text), costoStandard: _num(_regCosto.text), attiva: false); _newSetupRegola(); await _load(); }, icon: const Icon(Icons.block_outlined), label: const Text('Chiudi validita')),
          ]),
          const SizedBox(height: 12),
          _section('Regole del tipo selezionato', regoleMaster.map((r) => _selectableTile(label: _setupRegolaLabel(r), value: _setupRegolaValue(r), selected: _selectedSetupRegolaId == r.idSetupRegola, onTap: () => _selectSetupRegola(r))).toList()),
        ]);
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 360, child: master), const SizedBox(width: 12), Expanded(child: detail)]) : Column(children: [master, const SizedBox(height: 12), detail]);
      }),
    ]);
  }

  Widget _costiTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _form('Costo assegnato a linea / macchina', [
        _dropdown<int?>(label: 'Linea', value: _costoLinea, items: _linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label))).toList(), onChanged: (v) => setState(() => _costoLinea = v)),
        _dropdown<int?>(label: 'Macchina', value: _costoMacchinaId, items: [const DropdownMenuItem<int?>(value: null, child: Text('Tutta la linea')), ..._macchine.map((m) => DropdownMenuItem<int?>(value: m.idMacchina, child: Text(m.label)))], onChanged: (v) => setState(() => _costoMacchinaId = v)),
        OutlinedButton.icon(onPressed: _pickCostoDal, icon: const Icon(Icons.event_outlined), label: Text('Valido dal ${_date(_costoValidoDal)}')),
        _field(_costoFisso, 'Costo fisso/h', number: true), _field(_costoMacchina, 'Costo macchina/h', number: true), _field(_costoManodopera, 'Costo manodopera/h', number: true), _field(_costoEnergiaOra, 'Costo energia/h', number: true), _field(_costoEnergiaUnita, 'Costo energia/unita', number: true), _field(_costoNote, 'Note'),
        FilledButton.icon(onPressed: _saveCostoLinea, icon: const Icon(Icons.save_outlined), label: const Text('Salva costo linea')),
      ]),
      const SizedBox(height: 18),
      _section('Costi macchina/linea configurati', _costiLinea.map((c) => _tile('${c.codLinea}${c.codMacchina == null ? '' : ' - ${c.codMacchina}'}', 'Dal ${_date(c.validoDal)} - Fisso/h ${c.costoFissoOra ?? '-'} - Macchina/h ${c.costoMacchinaOra ?? '-'} - Manodopera/h ${c.costoManodoperaOra ?? '-'} - Energia/h ${c.costoEnergiaOra ?? '-'}')).toList()),
    ]);
  }

  Future<void> _pickCostoDal() async {
    final picked = await showDatePicker(context: context, initialDate: _costoValidoDal, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _costoValidoDal = picked);
  }

  String _setupRegolaLabel(SetupRegolaProduzione r) => r.codSetupTipo + ((r.codArticolo == null || r.codArticolo!.isEmpty) ? '' : ' - ' + r.codArticolo!);
  String _setupRegolaValue(SetupRegolaProduzione r) => 'Linea ' + (r.codLinea ?? '-') + ' - Macchina ' + (r.codMacchina ?? '-') + ' - Min ' + (r.tempoStandardMinuti?.toString() ?? '-') + ' - Costo ' + (r.costoStandard?.toString() ?? '-');

  Widget _hint(String text) => Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB7D3EF))), child: Text(text, style: const TextStyle(color: Color(0xFF174A7C), fontWeight: FontWeight.w700)));

  Widget _form(String title, List<Widget> children) => _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.end, children: children)]));
  Widget _section(String title, List<Widget> children) => _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), if (children.isEmpty) const Text('Nessun dato configurato.') else Wrap(spacing: 10, runSpacing: 10, children: children)]));
  Widget _panel(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))), child: child);
  Widget _field(TextEditingController c, String label, {bool number = false}) => SizedBox(width: 230, child: TextField(controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label)));
  Widget _dropdown<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) => SizedBox(width: 290, child: DropdownButtonFormField<T>(initialValue: value, isExpanded: true, decoration: InputDecoration(labelText: label), items: items, onChanged: onChanged));
  Widget _tile(String label, String value) => Container(width: 300, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Color(0xFF536273)))]));
  Widget _selectableTile({required String label, required String value, required bool selected, required VoidCallback onTap}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: selected ? const Color(0xFFE4F0FB) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? const Color(0xFF2F6FA5) : const Color(0xFFD7DDE5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Color(0xFF536273)), overflow: TextOverflow.ellipsis)]),
      ),
    ),
  );
  double? _num(String value) => double.tryParse(value.replaceAll(',', '.'));
  String _fmt(double value) => value.toStringAsFixed(2).replaceAll('.', ',');
  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  void _message(String text, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? const Color(0xFFB42318) : const Color(0xFF16803C)));
}









