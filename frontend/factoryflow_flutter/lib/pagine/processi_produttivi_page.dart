import 'package:flutter/material.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class ProcessiProduttiviPage extends StatefulWidget {
  const ProcessiProduttiviPage({super.key});

  @override
  State<ProcessiProduttiviPage> createState() => _ProcessiProduttiviPageState();
}

class _ProcessiProduttiviPageState extends State<ProcessiProduttiviPage> {
  static const _statiProcesso = ['BOZZA', 'VALIDO', 'SOSPESO', 'OBSOLETO'];

  final _service = ProduzioneService();
  final _codProcesso = TextEditingController();
  final _codArticolo = TextEditingController();
  final _descrizione = TextEditingController();
  final _note = TextEditingController();
  final _stato = TextEditingController(text: 'BOZZA');

  final _versioneDescrizione = TextEditingController();
  final _versioneMotivazione = TextEditingController();
  final _tempoAtteso = TextEditingController();
  final _setupAtteso = TextEditingController();
  final _produttivitaAttesa = TextEditingController();
  final _costoAtteso = TextEditingController();
  final _energiaAttesa = TextEditingController();

  final _faseSequenza = TextEditingController(text: '10');
  final _faseCodice = TextEditingController();
  final _faseDescrizione = TextEditingController();
  final _faseTempo = TextEditingController();
  final _faseSetup = TextEditingController();
  final _faseProduttivita = TextEditingController();
  final _faseCosto = TextEditingController();
  final _faseEnergia = TextEditingController();
  final _faseQualita = TextEditingController();
  final _faseScarto = TextEditingController();
  final _faseNote = TextEditingController();


  List<ProcessoProduttivo> _processi = [];
  List<VersioneProcesso> _versioni = [];
  List<FaseProcesso> _fasi = [];
  List<LineaProduzione> _linee = [];
  final List<ArticoloProduzione> _articoli = [];
  List<MacchinaProduzione> _macchine = [];
  List<TeamOperativo> _team = [];
  int? _selectedProcessoId;
  int? _selectedVersioneId;
  int? _selectedFaseId;
  int? _faseLineaId;
  int? _faseMacchinaId;
  int? _faseTeamId;
  ArticoloProduzione? _articoloSelezionato;
  bool _loading = true;
  bool _saving = false;
  bool _reqMacchina = true;
  bool _reqTeam = true;
  bool _reqSetup = false;
  bool _reqOrari = true;
  bool _reqArticolo = true;
  bool _reqLotto = true;
  bool _reqComponenti = true;
  bool _reqQualita = false;
  bool _reqNote = false;
  bool _generaErp = true;
  bool _generaCaricoPf = true;
  bool _generaScaricoComponenti = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    for (final c in [
      _codProcesso, _codArticolo, _descrizione, _note, _stato,
      _versioneDescrizione, _versioneMotivazione, _tempoAtteso, _setupAtteso,
      _produttivitaAttesa, _costoAtteso, _energiaAttesa,
      _faseSequenza, _faseCodice, _faseDescrizione, _faseTempo, _faseSetup,
      _faseProduttivita, _faseCosto, _faseEnergia, _faseQualita, _faseScarto, _faseNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final processi = await _service.getProcessi();
      final articoli = await _service.getArticoli();
      final linee = await _service.getLinee(soloAttive: false);
      final macchine = await _service.getMacchine();
      final team = await _service.getTeamOperativi();
      if (!mounted) return;
      setState(() {
        _processi = processi;
        _articoli
          ..clear()
          ..addAll(articoli);
        _linee = linee;
        _macchine = macchine;
        _team = team;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Errore caricamento processi: $e', error: true);
    }
  }

  Future<void> _selectProcesso(ProcessoProduttivo p) async {
    setState(() {
      _selectedProcessoId = p.idProcesso;
      _selectedVersioneId = null;
      _codProcesso.text = p.codProcesso;
      _codArticolo.text = p.codArticolo ?? '';
      _articoloSelezionato = _articoli.where((a) => a.codArticolo == p.codArticolo).cast<ArticoloProduzione?>().firstOrNull;
      _descrizione.text = p.descrizione;
      _note.text = p.note ?? '';
      _stato.text = _statiProcesso.contains(p.stato) ? p.stato : 'BOZZA';
      _versioni = [];
      _fasi = [];
      _clearVersionForm();
      _clearFaseForm();
    });
    await _loadVersioni(p.idProcesso);
  }

  Future<void> _loadVersioni(int idProcesso) async {
    try {
      final versioni = await _service.getVersioniProcesso(idProcesso);
      if (!mounted) return;
      setState(() {
        _versioni = versioni;
      });
      if (versioni.isNotEmpty) {
        await _selectVersione(versioni.first);
      }
    } catch (e) {
      _message('Errore caricamento versioni: $e', error: true);
    }
  }

  Future<void> _selectVersione(VersioneProcesso v) async {
    setState(() {
      _selectedVersioneId = v.idVersione;
      _versioneDescrizione.text = v.descrizione ?? '';
      _versioneMotivazione.text = v.motivazione ?? '';
      _tempoAtteso.text = _fmt(v.tempoAttesoMinuti);
      _setupAtteso.text = _fmt(v.setupAttesoMinuti);
      _produttivitaAttesa.text = _fmt(v.produttivitaAttesa);
      _costoAtteso.text = _fmt(v.costoAtteso);
      _energiaAttesa.text = _fmt(v.energiaAttesa);
      _fasi = [];
      _clearFaseForm();
    });
    await _loadFasi(v.idVersione);
  }

  Future<void> _loadFasi(int idVersione) async {
    try {
      final fasi = await _service.getFasiProcesso(idVersione);
      if (!mounted) return;
      setState(() => _fasi = fasi);
    } catch (e) {
      _message('Errore caricamento fasi: $e', error: true);
    }
  }

  void _nuovoProcesso() {
    setState(() {
      _selectedProcessoId = null;
      _selectedVersioneId = null;
      _codProcesso.clear();
      _codArticolo.clear();
      _articoloSelezionato = null;
      _descrizione.clear();
      _note.clear();
      _stato.text = 'BOZZA';
      _versioni = [];
      _fasi = [];
      _clearVersionForm();
      _clearFaseForm();
    });
  }

  void _clearVersionForm() {
    _versioneDescrizione.clear();
    _versioneMotivazione.clear();
    _tempoAtteso.clear();
    _setupAtteso.clear();
    _produttivitaAttesa.clear();
    _costoAtteso.clear();
    _energiaAttesa.clear();
  }

  void _clearFaseForm() {
    final next = _fasi.isEmpty ? 10 : ((_fasi.map((e) => e.sequenza).reduce((a, b) => a > b ? a : b) ~/ 10) + 1) * 10;
    _selectedFaseId = null;
    _faseSequenza.text = next.toString();
    _faseCodice.clear();
    _faseDescrizione.clear();
    _faseTempo.clear();
    _faseSetup.clear();
    _faseProduttivita.clear();
    _faseCosto.clear();
    _faseEnergia.clear();
    _faseQualita.clear();
    _faseScarto.clear();
    _faseNote.clear();
    _faseLineaId = null;
    _faseMacchinaId = null;
    _faseTeamId = null;
    _reqMacchina = false;
    _reqTeam = true;
    _reqSetup = false;
    _reqOrari = true;
    _reqArticolo = false;
    _reqLotto = false;
    _reqComponenti = false;
    _reqQualita = false;
    _reqNote = false;
    _generaErp = false;
    _generaCaricoPf = false;
    _generaScaricoComponenti = false;
  }

  void _selectFase(FaseProcesso f) {
    setState(() {
      _selectedFaseId = f.idFase;
      _faseSequenza.text = f.sequenza.toString();
      _faseCodice.text = f.codFase;
      _faseDescrizione.text = f.descrizione;
      _faseTempo.text = _fmt(f.tempoStandardMinuti);
      _faseSetup.text = _fmt(f.setupStandardMinuti);
      _faseProduttivita.text = _fmt(f.produttivitaAttesa);
      _faseCosto.text = _fmt(f.costoStandard);
      _faseEnergia.text = _fmt(f.energiaAttesa);
      _faseQualita.text = _fmt(f.qualitaAttesa);
      _faseScarto.text = _fmt(f.scartoAtteso);
      _faseNote.text = f.note ?? '';
      _faseLineaId = f.idLineaDefault;
      _faseMacchinaId = f.idMacchinaDefault;
      _faseTeamId = null;
      _reqMacchina = f.richiedeMacchina;
      _reqTeam = f.richiedeTeam;
      _reqSetup = f.richiedeSetup;
      _reqOrari = f.richiedeOrari;
      _reqArticolo = f.richiedeArticolo;
      _reqLotto = f.richiedeLotto;
      _reqComponenti = f.richiedeComponenti;
      _reqQualita = f.richiedeControlloQualita;
      _reqNote = f.richiedeNote;
      _generaErp = f.generaErp;
      _generaCaricoPf = f.generaCaricoPf;
      _generaScaricoComponenti = f.generaScaricoComponenti;
    });
  }

  Future<void> _saveProcesso() async {
    if (_codProcesso.text.trim().isEmpty || _descrizione.text.trim().isEmpty) {
      _message('Codice processo e descrizione sono obbligatori.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await _service.salvaProcesso(
        idProcesso: _selectedProcessoId,
        codProcesso: _codProcesso.text.trim(),
        codArticolo: _articoloSelezionato?.codArticolo,
        descrizione: _descrizione.text.trim(),
        note: _emptyToNull(_note.text),
        stato: _emptyToNull(_stato.text) ?? 'BOZZA',
      );
      await _loadAll();
      await _selectProcesso(saved);
      _message('Processo salvato.');
    } catch (e) {
      _message('Errore salvataggio processo: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveVersione() async {
    if (_selectedProcessoId == null) {
      _message('Salvare prima il processo produttivo.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final versioni = await _service.salvaVersioneProcesso(
        idProcesso: _selectedProcessoId!,
        idVersione: _selectedVersioneId,
        descrizione: _emptyToNull(_versioneDescrizione.text),
        motivazione: _emptyToNull(_versioneMotivazione.text),
        validoDal: DateTime.now(),
        stato: 'BOZZA',
        tempoAttesoMinuti: _num(_tempoAtteso),
        setupAttesoMinuti: _num(_setupAtteso),
        produttivitaAttesa: _num(_produttivitaAttesa),
        costoAtteso: _num(_costoAtteso),
        energiaAttesa: _num(_energiaAttesa),
      );
      if (!mounted) return;
      setState(() => _versioni = versioni);
      if (versioni.isNotEmpty) await _selectVersione(versioni.first);
      _message('Versione processo salvata.');
    } catch (e) {
      _message('Errore salvataggio versione: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveFase() async {
    if (_selectedVersioneId == null) {
      _message('Salvare prima una versione del processo.', error: true);
      return;
    }
    if (_faseCodice.text.trim().isEmpty || _faseDescrizione.text.trim().isEmpty) {
      _message('Codice fase e descrizione sono obbligatori.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final sequenza = int.tryParse(_faseSequenza.text.trim()) ?? 10;
      final codFase = _faseCodice.text.trim();
      final fasi = await _service.salvaFaseProcesso(
        idVersione: _selectedVersioneId!,
        idFase: _selectedFaseId,
        sequenza: sequenza,
        codFase: codFase,
        descrizione: _faseDescrizione.text.trim(),
        idLineaDefault: _faseLineaId,
        idMacchinaDefault: _faseMacchinaId,
        tempoStandardMinuti: _num(_faseTempo),
        setupStandardMinuti: _num(_faseSetup),
        produttivitaAttesa: _num(_faseProduttivita),
        costoStandard: _num(_faseCosto),
        energiaAttesa: _num(_faseEnergia),
        qualitaAttesa: _num(_faseQualita),
        scartoAtteso: _num(_faseScarto),
        note: _emptyToNull(_faseNote.text),
        richiedeMacchina: _reqMacchina,
        richiedeTeam: _reqTeam,
        richiedeSetup: _reqSetup,
        richiedeOrari: _reqOrari,
        richiedeArticolo: _reqArticolo,
        richiedeLotto: _reqLotto,
        richiedeComponenti: _reqComponenti,
        richiedeControlloQualita: _reqQualita,
        richiedeNote: _reqNote,
        generaErp: _generaErp,
        generaCaricoPf: _generaErp,
        generaScaricoComponenti: _generaErp,
      );
      final faseSalvata = fasi.where((f) => f.codFase == codFase && f.sequenza == sequenza).firstOrNull;
      if (faseSalvata != null && (_faseLineaId != null || _faseMacchinaId != null || _faseTeamId != null)) {
        await _service.salvaFaseRisorsa(
          idFase: faseSalvata.idFase,
          idLinea: _faseLineaId,
          idMacchina: _faseMacchinaId,
          idTeam: _faseTeamId,
          validoDal: DateTime.now(),
        );
      }
      if (!mounted) return;
      setState(() => _fasi = fasi);
      _clearFaseForm();
      _message(_selectedFaseId == null ? 'Fase aggiunta al processo.' : 'Fase aggiornata.');
    } catch (e) {
      _message('Errore salvataggio fase: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteFase() async {
    if (_selectedVersioneId == null || _selectedFaseId == null) {
      _message('Selezionare una fase da cancellare.', error: true);
      return;
    }
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellare la fase?'),
        content: const Text('Se la versione non e mai stata usata la fase verra eliminata. Se esistono dati storici, FactoryFlow blocchera la cancellazione e chiedera una nuova versione.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          FilledButton.tonalIcon(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.delete_outline), label: const Text('Cancella')),
        ],
      ),
    );
    if (conferma != true) return;
    setState(() => _saving = true);
    try {
      final fasi = await _service.eliminaFaseProcesso(idVersione: _selectedVersioneId!, idFase: _selectedFaseId!);
      if (!mounted) return;
      setState(() => _fasi = fasi);
      _clearFaseForm();
      _message('Fase cancellata.');
    } catch (e) {
      _message('Cancellazione non consentita: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 1050;
      final master = _buildMaster();
      final detail = _buildDetail(wide);
      if (!wide) {
        return ListView(padding: const EdgeInsets.all(12), children: [master, const SizedBox(height: 12), detail]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 410, child: master),
        const VerticalDivider(width: 1),
        Expanded(child: detail),
      ]);
    });
  }

  Widget _buildMaster() => ListView(
    padding: const EdgeInsets.all(12),
    shrinkWrap: true,
    children: [
      Row(children: [
        Expanded(child: Text('Processi produttivi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
        IconButton(onPressed: _nuovoProcesso, icon: const Icon(Icons.add), tooltip: 'Nuovo processo'),
      ]),
      const SizedBox(height: 8),
      if (_processi.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Nessun processo configurato.'))),
      ..._processi.map((p) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: _selectedProcessoId == p.idProcesso ? const Color(0xFFE1EEF9) : null,
        child: ListTile(
          onTap: () => _selectProcesso(p),
          title: Text(p.codProcesso, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${p.descrizione}\nArticolo ${p.codArticolo ?? '-'} • ${p.stato}', maxLines: 3, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
        ),
      )),
    ],
  );

  Widget _buildDetail(bool wide) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(_selectedProcessoId == null ? 'Nuovo processo produttivo' : 'Dettaglio processo produttivo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _notice(),
      const SizedBox(height: 12),
      _identityPanel(wide),
      _actions([FilledButton.icon(onPressed: _saving ? null : _saveProcesso, icon: const Icon(Icons.save_outlined), label: const Text('Salva processo'))]),
      const SizedBox(height: 12),
      _versionsPanel(wide),
      const SizedBox(height: 12),
      _phasesPanel(wide),
    ],
  );

  Widget _notice() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFFF8E6), border: Border.all(color: const Color(0xFFE7B642)), borderRadius: BorderRadius.circular(8)),
    child: const Text('Il processo produttivo e un percorso operativo composto da fasi. Ogni fase dichiara quali dati serviranno alla sua chiusura: macchina, team, orari, qualita o dichiarazione ERP. La distinta AdHoc resta fonte materiali quando la fase genera una dichiarazione.', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7A4F00))),
  );

  Widget _identityPanel(bool wide) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Identita del processo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(width: wide ? 270 : double.infinity, child: _field(_codProcesso, 'Codice processo *')),
        SizedBox(width: wide ? 270 : double.infinity, child: _field(_descrizione, 'Descrizione processo *')),
        SizedBox(width: wide ? 560 : double.infinity, child: _dropdownArticoli()),
        SizedBox(width: wide ? 560 : double.infinity, child: _statoProcessoSelector()),
        SizedBox(width: wide ? 560 : double.infinity, child: _field(_note, 'Note', lines: 2)),
      ]),
    ]),
  );

  Widget _statoProcessoSelector() => InputDecorator(
    decoration: const InputDecoration(labelText: 'Stato processo'),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statiProcesso.map((stato) => ChoiceChip(
        label: Text(stato),
        selected: _stato.text == stato,
        onSelected: (_) => setState(() => _stato.text = stato),
      )).toList(),
    ),
  );

  String get _umArticolo {
    final um = _articoloSelezionato?.unitaMisura.trim();
    return um == null || um.isEmpty ? 'UM' : um;
  }
  Widget _versionsPanel(bool wide) => _card(children: [
    Text('Versioni del processo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    if (_selectedProcessoId == null) const Text('Salvare il processo per creare una versione.') else Wrap(spacing: 8, runSpacing: 8, children: _versioni.map((v) => ChoiceChip(label: Text('v${v.numeroVersione} ${v.stato}'), selected: _selectedVersioneId == v.idVersione, onSelected: (_) => _selectVersione(v))).toList()),
    const SizedBox(height: 10),
    _panel('Parametri versione', [
      _field(_versioneDescrizione, 'Descrizione versione'),
      _field(_versioneMotivazione, 'Motivazione'),
      _field(_tempoAtteso, 'Tempo atteso min', number: true),
      _field(_setupAtteso, 'Setup atteso min', number: true),
      _field(_produttivitaAttesa, 'Produttivita attesa ($_umArticolo/min)'),
      _field(_costoAtteso, 'Costo atteso (EUR)', number: true),
      _field(_energiaAttesa, 'Energia attesa (kWh)', number: true),
    ], wide, embedded: true),
    _actions([FilledButton.tonalIcon(onPressed: _saving ? null : _saveVersione, icon: const Icon(Icons.save_as_outlined), label: const Text('Salva versione'))]),
  ]);

  Widget _phasesPanel(bool wide) => _card(children: [
    Text('Fasi operative', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    if (_fasi.isEmpty) const Text('Nessuna fase inserita.') else ..._fasi.map((f) => Card(
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        dense: true,
        onTap: () => _selectFase(f),
        leading: CircleAvatar(child: Text(f.sequenza.toString())),
        title: Text('${f.codFase} - ${f.descrizione}', style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${f.codLinea ?? 'Linea -'} • ${f.codMacchina ?? 'Macchina -'} • tempo ${_fmt(f.tempoStandardMinuti)} min'),
        trailing: IconButton(onPressed: () => _selectFase(f), icon: const Icon(Icons.edit_outlined), tooltip: 'Modifica fase'),
      ),
    )),
    const SizedBox(height: 8),
    const Divider(height: 22),
    _panel(_selectedFaseId == null ? 'Nuova fase' : 'Modifica fase', [
      _field(_faseSequenza, 'Sequenza *', number: true),
      _field(_faseCodice, 'Codice fase *'),
      _field(_faseDescrizione, 'Descrizione fase *'),
      _dropdownLinee(),
      _dropdownMacchine(),
      _dropdownTeamFase(),
      _field(_faseTempo, 'Tempo standard min', number: true),
      _field(_faseSetup, 'Setup standard min', number: true),
      _field(_faseProduttivita, 'Produttivita attesa ($_umArticolo/min)', number: true),
      _field(_faseCosto, 'Costo standard (EUR)', number: true),
      _field(_faseEnergia, 'Energia attesa (kWh)', number: true),
      _field(_faseQualita, 'Qualita attesa %', number: true),
      _field(_faseScarto, 'Scarto atteso %', number: true),
      _field(_faseNote, 'Note', lines: 2),
    ], wide, embedded: true),
    const SizedBox(height: 12),
    _requisitiFasePanel(wide),
    _actions([
      FilledButton.icon(onPressed: _saving ? null : _saveFase, icon: Icon(_selectedFaseId == null ? Icons.add_task_outlined : Icons.save_outlined), label: Text(_selectedFaseId == null ? 'Aggiungi fase' : 'Salva fase')),
      OutlinedButton.icon(onPressed: _saving ? null : () => setState(_clearFaseForm), icon: const Icon(Icons.add_outlined), label: const Text('Nuova fase')),
      if (_selectedFaseId != null) OutlinedButton.icon(onPressed: _saving ? null : _deleteFase, icon: const Icon(Icons.delete_outline), label: const Text('Cancella fase')),
    ]),
  ]);
  Widget _requisitiFasePanel(bool wide) => InputDecorator(
    decoration: const InputDecoration(labelText: 'Dati richiesti alla chiusura della fase'),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _reqChip('Macchina', _reqMacchina, (v) => _reqMacchina = v),
        _reqChip('Team', _reqTeam, (v) => _reqTeam = v),
        _reqChip('Setup', _reqSetup, (v) => _reqSetup = v),
        _reqChip('Orari', _reqOrari, (v) => _reqOrari = v),
        _reqChip('Articolo', _reqArticolo, (v) => _reqArticolo = v),
        _reqChip('Lotto', _reqLotto, (v) => _reqLotto = v),
        _reqChip('Componenti', _reqComponenti, (v) => _reqComponenti = v),
        _reqChip('Qualita', _reqQualita, (v) => _reqQualita = v),
        _reqChip('Note', _reqNote, (v) => _reqNote = v),
        _reqChip('Genera ERP', _generaErp, (v) => _generaErp = v),
        _reqChip('Carico PF', _generaCaricoPf, (v) => _generaCaricoPf = v),
        _reqChip('Scarico comp.', _generaScaricoComponenti, (v) => _generaScaricoComponenti = v),
      ],
    ),
  );

  Widget _reqChip(String label, bool value, ValueChanged<bool> onChanged) => FilterChip(
    label: Text(label),
    selected: value,
    onSelected: (selected) => setState(() => onChanged(selected)),
  );
  Widget _panel(String title, List<Widget> children, bool wide, {bool embedded = false}) => Padding(
    padding: embedded ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title.isNotEmpty) ...[Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8)],
      Wrap(spacing: 10, runSpacing: 10, children: children.map((w) => SizedBox(width: wide ? 270 : double.infinity, child: w)).toList()),
    ]),
  );

  Widget _card({required List<Widget> children}) => Card(
    elevation: 0,
    color: const Color(0xFFF8FAFC),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
  );

  Widget _field(TextEditingController controller, String label, {bool number = false, int lines = 1}) => TextField(
    controller: controller,
    minLines: lines,
    maxLines: lines,
    keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    decoration: InputDecoration(labelText: label),
  );

  Widget _dropdownArticoli() => DropdownButtonFormField<ArticoloProduzione>(
    initialValue: _articoloSelezionato,
    decoration: const InputDecoration(labelText: 'Articolo AdHoc di riferimento (facoltativo)'),
    isExpanded: true,
    items: _articoli.map((a) => DropdownMenuItem<ArticoloProduzione>(value: a, child: _articoloItem(a))).toList(),
    onChanged: (value) => setState(() {
      _articoloSelezionato = value;
      _codArticolo.text = value?.codArticolo ?? '';
      if (value != null && _descrizione.text.trim().isEmpty) {
        _descrizione.text = value.descrizione;
      }
      if (value != null && _codProcesso.text.trim().isEmpty) {
        _codProcesso.text = 'PROC-${value.codArticolo}';
      }
    }),
  );

  Widget _articoloItem(ArticoloProduzione articolo) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(articolo.descrizione, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
      Text('${articolo.codArticolo} - UM ${articolo.unitaMisura.isEmpty ? '-' : articolo.unitaMisura}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF536273))),
    ],
  );
  Widget _dropdownTeamFase() => DropdownButtonFormField<int?>(
    initialValue: _faseTeamId,
    decoration: const InputDecoration(labelText: 'Team fase'),
    isExpanded: true,
    items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessun team')), ..._team.where((t) => t.attivo).map((t) => DropdownMenuItem<int?>(value: t.idTeam, child: Text(t.label, overflow: TextOverflow.ellipsis)))],
    onChanged: (v) => setState(() => _faseTeamId = v),
  );
  Widget _dropdownLinee() => DropdownButtonFormField<int?>(
    initialValue: _faseLineaId,
    decoration: const InputDecoration(labelText: 'Linea default'),
    items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna linea')), ..._linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label, overflow: TextOverflow.ellipsis)))],
    onChanged: (v) => setState(() => _faseLineaId = v),
  );

  Widget _dropdownMacchine() => DropdownButtonFormField<int?>(
    initialValue: _faseMacchinaId,
    decoration: const InputDecoration(labelText: 'Macchina default'),
    items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna macchina')), ..._macchine.map((m) => DropdownMenuItem<int?>(value: m.idMacchina, child: Text(m.label, overflow: TextOverflow.ellipsis)))],
    onChanged: (v) => setState(() => _faseMacchinaId = v),
  );
  Widget _actions(List<Widget> children) => Padding(padding: const EdgeInsets.only(top: 10), child: Wrap(spacing: 10, runSpacing: 10, children: children));

  String? _emptyToNull(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  double? _num(TextEditingController controller) => double.tryParse(controller.text.trim().replaceAll(',', '.'));
  String _fmt(double? value) => value == null ? '-' : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  void _message(String text, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700));
}

































