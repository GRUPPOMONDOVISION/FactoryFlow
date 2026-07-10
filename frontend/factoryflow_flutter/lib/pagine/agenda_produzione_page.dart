import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class AgendaProduzionePage extends StatefulWidget {
  const AgendaProduzionePage({super.key});

  @override
  State<AgendaProduzionePage> createState() => _AgendaProduzionePageState();
}

class _AgendaProduzionePageState extends State<AgendaProduzionePage> {
  final _service = ProduzioneService();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _quantita = TextEditingController(text: '1');
  final _note = TextEditingController();

  DateTime _mese = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _giorno = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List<AttivitaProduttiva> _attivita = [];
  List<ArticoloProduzione> _articoli = [];
  List<ProcessoProduttivo> _processi = [];
  List<VersioneProcesso> _versioni = [];
  List<FaseProcesso> _fasi = [];
  List<LineaProduzione> _linee = [];
  List<MacchinaProduzione> _macchine = [];
  List<TeamOperativo> _team = [];
  List<ChiusuraFase> _chiusure = [];

  AttivitaProduttiva? _selected;
  String? _codArticolo;
  int? _idProcesso;
  int? _idVersione;
  int? _idFase;
  int? _idLinea;
  int? _idMacchina;
  int? _idTeam;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  @override
  void dispose() {
    _quantita.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    try {
      final dal = DateTime(_mese.year, _mese.month, 1);
      final al = DateTime(_mese.year, _mese.month + 1, 0);
      final results = await Future.wait([
        _service.getAttivitaProduttive(dal, al),
        _service.getArticoli(),
        _service.getProcessi(),
        _service.getLinee(soloAttive: false),
        _service.getMacchine(),
        _service.getTeamOperativi(),
      ]);
      if (!mounted) return;
      setState(() {
        _attivita = results[0] as List<AttivitaProduttiva>;
        _articoli = results[1] as List<ArticoloProduzione>;
        _processi = results[2] as List<ProcessoProduttivo>;
        _linee = results[3] as List<LineaProduzione>;
        _macchine = results[4] as List<MacchinaProduzione>;
        _team = results[5] as List<TeamOperativo>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Errore caricamento agenda: $e', error: true);
    }
  }

  void _changeYear(int delta) {
    setState(() {
      _mese = DateTime(_mese.year + delta, _mese.month);
      _giorno = DateTime(_mese.year, _mese.month, 1);
      _selected = null;
    });
    _loadMonth();
  }

  void _selectMonth(int month) {
    setState(() {
      _mese = DateTime(_mese.year, month);
      _giorno = DateTime(_mese.year, month, 1);
      _selected = null;
    });
    _loadMonth();
  }

  void _newActivity() {
    setState(() {
      _selected = null;
      _codArticolo = null;
      _idProcesso = null;
      _idVersione = null;
      _idFase = null;
      _idLinea = null;
      _idMacchina = null;
      _idTeam = null;
      _versioni = [];
      _fasi = [];
      _quantita.text = '1';
      _note.clear();
    });
  }

  Future<void> _selectActivity(AttivitaProduttiva a) async {
    setState(() {
      _selected = a;
      _giorno = a.dataProduzione;
      _codArticolo = a.codArticolo;
      _idProcesso = a.idProcesso;
      _idVersione = a.idVersione;
      _idFase = a.idFase;
      _idLinea = a.idLinea;
      _idMacchina = a.idMacchina;
      _idTeam = a.idTeam;
      _quantita.text = _fmt(a.quantitaPrevista);
      _note.text = a.note ?? '';
      _versioni = [];
      _fasi = [];
    });
    await _loadChiusure(a.idAttivita);
    if (_idProcesso != null) await _loadVersioni(_idProcesso!, selectVersione: _idVersione, selectFase: _idFase);
  }

  Future<void> _loadVersioni(int idProcesso, {int? selectVersione, int? selectFase}) async {
    try {
      final versioni = await _service.getVersioniProcesso(idProcesso);
      if (!mounted) return;
      final versione = selectVersione ?? (versioni.isEmpty ? null : versioni.first.idVersione);
      setState(() {
        _versioni = versioni;
        _idVersione = versione;
        _fasi = [];
        _idFase = null;
      });
      if (versione != null) await _loadFasi(versione, selectFase: selectFase);
    } catch (e) {
      _snack('Errore caricamento versioni: $e', error: true);
    }
  }


  Future<void> _loadChiusure(int idAttivita) async {
    try {
      final rows = await _service.getChiusureFase(idAttivita: idAttivita);
      if (!mounted) return;
      setState(() => _chiusure = rows);
    } catch (e) {
      _snack('Errore caricamento chiusure fase: $e', error: true);
    }
  }

  ChiusuraFase? _chiusuraFor(FaseProcesso fase) {
    final rows = _chiusure.where((c) => c.idFase == fase.idFase).toList();
    if (rows.isEmpty) return null;
    rows.sort((a, b) => b.idChiusuraFase.compareTo(a.idChiusuraFase));
    return rows.first;
  }
  Future<void> _loadFasi(int idVersione, {int? selectFase}) async {
    try {
      final fasi = await _service.getFasiProcesso(idVersione);
      if (!mounted) return;
      setState(() {
        _fasi = fasi;
        _idFase = selectFase ?? (fasi.isEmpty ? null : fasi.first.idFase);
      });
    } catch (e) {
      _snack('Errore caricamento fasi: $e', error: true);
    }
  }

  Future<void> _saveActivity() async {
    if (_idVersione == null || _idFase == null) {
      _snack('Selezionare processo, versione e fase iniziale.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await _service.salvaAttivitaProduttiva(
        idAttivita: _selected?.idAttivita == 0 ? null : _selected?.idAttivita,
        idVersione: _idVersione!,
        idFase: _idFase!,
        dataProduzione: _giorno,
        stato: _selected?.stato ?? 'PREVISTA',
        codArticolo: _codArticolo,
        quantitaPrevista: _num(_quantita.text),
        idLinea: _idLinea,
        idMacchina: _idMacchina,
        idTeam: _idTeam,
        note: _emptyToNull(_note.text),
      );
      await _loadMonth();
      await _selectActivity(saved);
      _snack('Attivita agenda salvata.');
    } catch (e) {
      _snack('Errore salvataggio attivita: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _closePhase(FaseProcesso fase, {ChiusuraFase? chiusura}) async {
    var dataChiusura = chiusura?.dataChiusura ?? _giorno;
    var idLinea = chiusura?.idLinea ?? _idLinea;
    var idMacchina = chiusura?.idMacchina ?? _idMacchina;
    var idTeam = chiusura?.idTeam ?? _idTeam;
    var codArticolo = chiusura?.codArticolo ?? _codArticolo;
    var articolo = _articoli.where((a) => a.codArticolo == codArticolo).cast<ArticoloProduzione?>().firstOrNull;
    var quantita = chiusura?.quantita ?? _num(_quantita.text);
    var lotto = chiusura?.lotto ?? '';
    var magazzino = chiusura?.magazzino ?? '01';
    var note = chiusura?.note ?? _note.text;
    TimeOfDay? oraInizio = _timeFromDateTime(chiusura?.oraInizio);
    TimeOfDay? oraFine = _timeFromDateTime(chiusura?.oraFine);
    var componenti = chiusura?.componenti.map((c) => c.toComponenteDistinta()).toList() ?? <ComponenteDistinta>[];
    var loadingDistinta = false;

    DateTime? combine(TimeOfDay? value) => value == null ? null : DateTime(dataChiusura.year, dataChiusura.month, dataChiusura.day, value.hour, value.minute);

    Future<void> caricaDistinta(StateSetter setDialogState) async {
      if (codArticolo == null || codArticolo!.trim().isEmpty || quantita == null || quantita! <= 0) {
        _snack('Per caricare la distinta servono articolo e quantita.', error: true);
        return;
      }
      setDialogState(() => loadingDistinta = true);
      try {
        final distinta = await _service.getDistinta(codArticolo!, quantita!);
        for (final componente in distinta.componenti) {
          if (componente.gestioneLotti) {
            componente.lotti = await _service.getLotti(componente.codComponente, componente.magazzino, dataChiusura);
            if (componente.lotti.isNotEmpty) componente.lotto = componente.lotti.first.codiceLotto;
          }
        }
        setDialogState(() {
          componenti = distinta.componenti;
          loadingDistinta = false;
        });
      } catch (e) {
        setDialogState(() => loadingDistinta = false);
        _snack('Errore caricamento distinta fase: $e', error: true);
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final wide = MediaQuery.of(context).size.width >= 900;
          Widget box(Widget child, {double? width}) => SizedBox(width: wide ? (width ?? 280) : double.infinity, child: child);
          return AlertDialog(
            title: Text('Chiusura fase ${fase.codFase}'),
            content: SizedBox(
              width: wide ? 980 : double.maxFinite,
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(fase.descrizione, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _RequisitiFasePanel(fase: fase, chiusura: chiusura),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    box(OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: dataChiusura, firstDate: DateTime(2020), lastDate: DateTime(2100));
                        if (picked != null) setDialogState(() => dataChiusura = picked);
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(_dateFormat.format(dataChiusura)),
                    )),
                    if (fase.richiedeOrari) box(OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: oraInizio ?? const TimeOfDay(hour: 8, minute: 0));
                        if (picked != null) setDialogState(() => oraInizio = picked);
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text('Inizio ${oraInizio == null ? '-' : oraInizio!.format(context)}'),
                    )),
                    if (fase.richiedeOrari) box(OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: oraFine ?? const TimeOfDay(hour: 9, minute: 0));
                        if (picked != null) setDialogState(() => oraFine = picked);
                      },
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: Text('Fine ${oraFine == null ? '-' : oraFine!.format(context)}'),
                    )),
                    if (fase.richiedeMacchina) box(DropdownButtonFormField<int?>(
                      initialValue: idMacchina,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Macchina utilizzata'),
                      items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna macchina')), ..._macchine.map((m) => DropdownMenuItem<int?>(value: m.idMacchina, child: Text(m.label, overflow: TextOverflow.ellipsis)))],
                      onChanged: (v) => setDialogState(() => idMacchina = v),
                    )),
                    if (fase.richiedeTeam) box(DropdownButtonFormField<int?>(
                      initialValue: idTeam,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Team consuntivo'),
                      items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessun team')), ..._team.map((t) => DropdownMenuItem<int?>(value: t.idTeam, child: Text(t.label, overflow: TextOverflow.ellipsis)))],
                      onChanged: (v) => setDialogState(() => idTeam = v),
                    )),
                    if (fase.richiedeArticolo || fase.generaErp) box(DropdownButtonFormField<String>(
                      initialValue: codArticolo,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Articolo dichiarato'),
                      items: _articoli.map((a) => DropdownMenuItem(value: a.codArticolo, child: Text(a.label, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setDialogState(() { codArticolo = v; articolo = _articoli.where((a) => a.codArticolo == v).cast<ArticoloProduzione?>().firstOrNull; componenti = []; }),
                    ), width: 420),
                    if (fase.generaErp) box(TextFormField(
                      initialValue: quantita == null ? '' : _fmt(quantita),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Quantita dichiarata'),
                      onChanged: (v) => quantita = _num(v),
                    )),
                    if (fase.richiedeLotto || fase.generaErp) box(TextFormField(
                      initialValue: lotto,
                      decoration: const InputDecoration(labelText: 'Lotto prodotto'),
                      onChanged: (v) => lotto = v,
                    )),
                    if (fase.generaErp) box(TextFormField(
                      initialValue: magazzino,
                      decoration: const InputDecoration(labelText: 'Magazzino prodotto'),
                      onChanged: (v) => magazzino = v,
                    )),
                    box(TextFormField(
                      initialValue: note,
                      decoration: const InputDecoration(labelText: 'Note chiusura'),
                      onChanged: (v) => note = v,
                    ), width: 580),
                  ]),
                  if (fase.richiedeComponenti || fase.generaErp) ...[
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Text('Componenti da distinta AdHoc', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                      FilledButton.tonalIcon(onPressed: loadingDistinta ? null : () => caricaDistinta(setDialogState), icon: const Icon(Icons.refresh_outlined), label: const Text('Carica distinta')),
                    ]),
                    const SizedBox(height: 8),
                    if (loadingDistinta) const LinearProgressIndicator(),
                    if (!loadingDistinta && componenti.isEmpty) const Text('Caricare la distinta per dichiarare i componenti consumati.'),
                    ...componenti.map((c) => Card(
                      elevation: 0,
                      color: const Color(0xFFF8FAFC),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
                          SizedBox(width: wide ? 260 : double.infinity, child: Text('${c.codComponente}\n${c.descrizione}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                          SizedBox(width: 130, child: TextFormField(
                            initialValue: _fmt(c.quantitaDaScaricare),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Quantita'),
                            onChanged: (v) => c.quantitaDaScaricare = _num(v) ?? c.quantitaDaScaricare,
                          )),
                          if (c.gestioneLotti && c.lotti.isNotEmpty) SizedBox(width: wide ? 260 : double.infinity, child: DropdownButtonFormField<String>(
                            initialValue: c.lotto,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Lotto componente'),
                            items: c.lotti.map((l) => DropdownMenuItem(value: l.codiceLotto, child: Text('${l.codiceLotto} - disp. ${_fmt(l.disponibilita)}', overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setDialogState(() => c.lotto = v),
                          )),
                          if (c.gestioneLotti && c.lotti.isEmpty) SizedBox(width: wide ? 260 : double.infinity, child: TextFormField(
                            initialValue: c.lotto ?? '',
                            decoration: const InputDecoration(labelText: 'Lotto componente'),
                            onChanged: (v) => c.lotto = v,
                          )),
                          SizedBox(width: 90, child: Text(c.unitaMisura, style: const TextStyle(fontWeight: FontWeight.w700))),
                        ]),
                      ),
                    )),
                  ],
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
              FilledButton.icon(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.task_alt_outlined), label: const Text('Conferma chiusura')),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;
    if (fase.richiedeOrari && (oraInizio == null || oraFine == null)) {
      _snack('La fase richiede ora inizio e ora fine.', error: true);
      return;
    }
    if (fase.richiedeMacchina && idMacchina == null) {
      _snack('La fase richiede la macchina utilizzata.', error: true);
      return;
    }
    if (fase.richiedeTeam && idTeam == null) {
      _snack('La fase richiede il team consuntivo.', error: true);
      return;
    }
    if ((fase.richiedeArticolo || fase.generaErp) && articolo == null) {
      _snack('La fase richiede l\'articolo dichiarato.', error: true);
      return;
    }
    if ((fase.richiedeLotto || fase.generaErp) && lotto.trim().isEmpty) {
      _snack('La fase richiede il lotto prodotto.', error: true);
      return;
    }
    if ((fase.richiedeComponenti || fase.generaErp) && componenti.isEmpty) {
      _snack('La fase richiede i componenti consumati.', error: true);
      return;
    }

    try {
      final message = await _service.confermaChiusuraFase(
        idChiusuraFase: chiusura?.idChiusuraFase == 0 ? null : chiusura?.idChiusuraFase,
        idAttivita: _selected?.idAttivita == 0 ? null : _selected?.idAttivita,
        idFase: fase.idFase,
        idLinea: idLinea,
        idMacchina: idMacchina,
        idTeam: idTeam,
        articoloProdotto: articolo?.codArticolo,
        descrizioneProdotto: articolo?.descrizione,
        quantita: quantita,
        dataProduzione: dataChiusura,
        oraInizio: combine(oraInizio),
        oraFine: combine(oraFine),
        lottoProdotto: lotto.trim().isEmpty ? null : lotto.trim(),
        magazzinoProdotto: magazzino.trim().isEmpty ? '01' : magazzino.trim(),
        componenti: componenti,
        operatori: const [],
        note: _emptyToNull(note),
      );
      await _loadMonth();
      _snack(message);
    } catch (e) {
      _snack('Errore chiusura fase: $e', error: true);
    }
  }
  List<AttivitaProduttiva> get _attivitaGiorno => _attivita.where((a) => _sameDay(a.dataProduzione, _giorno)).toList();

  Map<String, int> get _conteggi {
    final map = <String, int>{};
    for (final a in _attivita) {
      final key = _dateKey(a.dataProduzione);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1000;
      final mobile = constraints.maxWidth < 700;
      final master = _buildMaster(mobile: mobile);
      final detail = _buildDetail(desktop: desktop);
      if (desktop) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 480, child: SingleChildScrollView(child: master)),
            const SizedBox(width: 16),
            Expanded(child: SingleChildScrollView(child: detail)),
          ]),
        );
      }
      return ListView(padding: EdgeInsets.all(mobile ? 12 : 16), children: [master, const SizedBox(height: 16), detail]);
    });
  }

  Widget _buildMaster({required bool mobile}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      IconButton.filledTonal(style: _agendaIconStyle(), onPressed: () => _changeYear(-1), icon: const Icon(Icons.chevron_left)),
      Expanded(child: Text('Agenda ${_mese.year}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF4A2D73)))),
      IconButton.filledTonal(style: _agendaIconStyle(), onPressed: () => _changeYear(1), icon: const Icon(Icons.chevron_right)),
      if (!mobile) ...[const SizedBox(width: 8), FilledButton.icon(style: _agendaButtonStyle(), onPressed: _newActivity, icon: const Icon(Icons.add), label: const Text('Nuova'))],
    ]),
    const SizedBox(height: 12),
    _MonthScroller(selectedMonth: _mese.month, onSelected: _selectMonth),
    const SizedBox(height: 12),
    Text(_monthLabel(_mese), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    _AgendaCalendarGrid(mese: _mese, selected: _giorno, counts: _conteggi, onSelected: (date) => setState(() { _giorno = date; _selected = null; })),
    const SizedBox(height: 16),
    Text('Attivita del ${_dateFormat.format(_giorno)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 10),
    if (_attivitaGiorno.isEmpty)
      const _AgendaEmptyPanel(icon: Icons.event_available_outlined, text: 'Nessuna attivita agenda in questa data.')
    else
      ..._attivitaGiorno.map((a) => _AgendaTile(row: a, selected: _selected?.idAttivita == a.idAttivita, onTap: () => _selectActivity(a))),
  ]);

  Widget _buildDetail({required bool desktop}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD9C8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_selected == null ? 'Nuova attivita agenda' : 'Dettaglio attivita agenda', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      _notice(),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(width: desktop ? 270 : double.infinity, child: OutlinedButton.icon(style: _agendaOutlinedStyle(), onPressed: () async { final picked = await showDatePicker(context: context, initialDate: _giorno, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) setState(() => _giorno = picked); }, icon: const Icon(Icons.calendar_month_outlined), label: Text(_dateFormat.format(_giorno)))),
        SizedBox(width: desktop ? 430 : double.infinity, child: _articoloDropdown()),
        SizedBox(width: desktop ? 180 : double.infinity, child: _field(_quantita, 'Quantita prevista', number: true)),
        SizedBox(width: desktop ? 360 : double.infinity, child: _processoDropdown()),
        SizedBox(width: desktop ? 220 : double.infinity, child: _versioneDropdown()),
        SizedBox(width: desktop ? 360 : double.infinity, child: _faseDropdown()),
        SizedBox(width: desktop ? 320 : double.infinity, child: _lineaDropdown()),
        SizedBox(width: desktop ? 320 : double.infinity, child: _macchinaDropdown()),
        SizedBox(width: desktop ? 320 : double.infinity, child: _teamDropdown()),
        SizedBox(width: desktop ? 650 : double.infinity, child: _field(_note, 'Note', lines: 2)),
      ]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: _agendaButtonStyle(), onPressed: _saving ? null : _saveActivity, icon: const Icon(Icons.save_outlined), label: const Text('Salva attivita agenda'))),
      const SizedBox(height: 18),
      Text('Fasi previste', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      if (_fasi.isEmpty) const Text('Selezionare un processo/versione per vedere le fasi.') else ..._fasi.map(_faseTile),
    ]),
  );

  Widget _notice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF3EAFE), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB999E6))),
    child: const Text('Agenda Produzione governa il processo: pianifica attivita, mostra fasi e consente la chiusura delle singole fasi. Il Calendario Dichiarazioni resta il flusso diretto MVP.', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4A2D73))),
  );

  Widget _faseTile(FaseProcesso fase) {
    final chiusura = _chiusuraFor(fase);
    final closed = chiusura != null;
    final subtitle = <Widget>[
      Wrap(spacing: 8, runSpacing: 4, children: [
        if (fase.generaErp) const Chip(label: Text('Dichiarazione ERP'), avatar: Icon(Icons.receipt_long_outlined, size: 16)),
        if (fase.richiedeMacchina) const Chip(label: Text('Macchina')),
        if (fase.richiedeTeam) const Chip(label: Text('Team')),
        if (fase.richiedeComponenti) const Chip(label: Text('Componenti')),
      ]),
      if (closed) ...[
        const SizedBox(height: 6),
        Text(
          'Chiusa il ${_dateFormat.format(chiusura.dataChiusura)}'
          '${chiusura.oraInizio == null ? '' : ' - ${DateFormat('HH:mm').format(chiusura.oraInizio!)}'}'
          '${chiusura.oraFine == null ? '' : '/${DateFormat('HH:mm').format(chiusura.oraFine!)}'}'
          '${chiusura.macchinaLabel.isEmpty ? '' : ' - ${chiusura.macchinaLabel}'}'
          '${chiusura.teamLabel.isEmpty ? '' : ' - ${chiusura.teamLabel}'}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF166534)),
        ),
        if ((chiusura.codArticolo ?? '').trim().isNotEmpty || chiusura.quantita != null || (chiusura.lotto ?? '').trim().isNotEmpty)
          Text('Articolo ${chiusura.codArticolo ?? '-'} - Qta ${_fmt(chiusura.quantita)} - Lotto ${chiusura.lotto ?? '-'}'),
        if (chiusura.generatoErp)
          Text('ERP carico ${chiusura.serialCaricoAdhoc ?? '-'} / ${chiusura.numeroCaricoAdhoc ?? '-'} - scarico ${chiusura.serialScaricoAdhoc ?? '-'} / ${chiusura.numeroScaricoAdhoc ?? '-'}'),
      ],
    ];
    return Card(
      elevation: 0,
      color: closed ? const Color(0xFFEAF7EE) : (_idFase == fase.idFase ? const Color(0xFFF7F0FF) : Colors.white),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: closed ? const Color(0xFFBBF7D0) : const Color(0xFFDCC7FF), foregroundColor: closed ? const Color(0xFF166534) : const Color(0xFF4A2D73), child: closed ? const Icon(Icons.check, size: 18) : Text(fase.sequenza.toString())),
        title: Text('${fase.codFase} - ${fase.descrizione}', style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: subtitle),
        trailing: FilledButton.tonalIcon(
          onPressed: () => _closePhase(fase, chiusura: chiusura),
          icon: Icon(closed ? Icons.edit_outlined : Icons.task_alt_outlined),
          label: Text(closed ? 'Vedi/modifica' : 'Chiudi fase'),
        ),
      ),
    );
  }
  Widget _articoloDropdown() => DropdownButtonFormField<String>(initialValue: _codArticolo, isExpanded: true, decoration: const InputDecoration(labelText: 'Articolo da produrre'), items: _articoli.map((a) => DropdownMenuItem(value: a.codArticolo, child: Text(a.label, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => _codArticolo = v));
  Widget _processoDropdown() => DropdownButtonFormField<int>(initialValue: _idProcesso, isExpanded: true, decoration: const InputDecoration(labelText: 'Processo produttivo'), items: _processi.map((p) => DropdownMenuItem(value: p.idProcesso, child: Text('${p.codProcesso} - ${p.descrizione}', overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) { setState(() { _idProcesso = v; _idVersione = null; _idFase = null; _versioni = []; _fasi = []; }); if (v != null) _loadVersioni(v); });
  Widget _versioneDropdown() => DropdownButtonFormField<int>(initialValue: _idVersione, isExpanded: true, decoration: const InputDecoration(labelText: 'Versione'), items: _versioni.map((v) => DropdownMenuItem(value: v.idVersione, child: Text('v${v.numeroVersione} - ${v.stato}'))).toList(), onChanged: (v) { setState(() { _idVersione = v; _idFase = null; _fasi = []; }); if (v != null) _loadFasi(v); });
  Widget _faseDropdown() => DropdownButtonFormField<int>(initialValue: _idFase, isExpanded: true, decoration: const InputDecoration(labelText: 'Fase iniziale / corrente'), items: _fasi.map((f) => DropdownMenuItem(value: f.idFase, child: Text(f.label, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => _idFase = v));
  Widget _lineaDropdown() => DropdownButtonFormField<int?>(initialValue: _idLinea, isExpanded: true, decoration: const InputDecoration(labelText: 'Linea prevista'), items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna linea')), ..._linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label, overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => _idLinea = v));
  Widget _macchinaDropdown() => DropdownButtonFormField<int?>(initialValue: _idMacchina, isExpanded: true, decoration: const InputDecoration(labelText: 'Macchina prevista'), items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna macchina')), ..._macchine.map((m) => DropdownMenuItem<int?>(value: m.idMacchina, child: Text(m.label, overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => _idMacchina = v));
  Widget _teamDropdown() => DropdownButtonFormField<int?>(initialValue: _idTeam, isExpanded: true, decoration: const InputDecoration(labelText: 'Team previsto'), items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessun team')), ..._team.map((t) => DropdownMenuItem<int?>(value: t.idTeam, child: Text(t.label, overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => _idTeam = v));
  Widget _field(TextEditingController controller, String label, {bool number = false, int lines = 1}) => TextField(controller: controller, minLines: lines, maxLines: lines, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label));

  ButtonStyle _agendaButtonStyle() => FilledButton.styleFrom(backgroundColor: const Color(0xFF6D3FB1), foregroundColor: Colors.white);
  ButtonStyle _agendaIconStyle() => IconButton.styleFrom(backgroundColor: const Color(0xFFE7D8FF), foregroundColor: const Color(0xFF4A2D73));
  ButtonStyle _agendaOutlinedStyle() => OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4A2D73), side: const BorderSide(color: Color(0xFF8E63CF)));

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _dateKey(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  String _monthLabel(DateTime value) => DateFormat('MMMM yyyy', 'it_IT').format(value).replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
  TimeOfDay? _timeFromDateTime(DateTime? value) => value == null ? null : TimeOfDay(hour: value.hour, minute: value.minute);
  double? _num(String value) => double.tryParse(value.trim().replaceAll(',', '.'));
  String _fmt(double? value) => value == null ? '' : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 3);
  String? _emptyToNull(String value) => value.trim().isEmpty ? null : value.trim();

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? Colors.red.shade700 : const Color(0xFF6D3FB1)));
  }
}

class _RequisitiFasePanel extends StatelessWidget {
  const _RequisitiFasePanel({required this.fase, required this.chiusura});

  final FaseProcesso fase;
  final ChiusuraFase? chiusura;

  @override
  Widget build(BuildContext context) {
    final requisiti = <String>[
      if (fase.richiedeOrari) 'Orari',
      if (fase.richiedeMacchina) 'Macchina',
      if (fase.richiedeTeam) 'Team',
      if (fase.richiedeSetup) 'Setup',
      if (fase.richiedeArticolo) 'Articolo',
      if (fase.richiedeLotto) 'Lotto',
      if (fase.richiedeComponenti) 'Componenti',
      if (fase.richiedeControlloQualita) 'Qualita',
      if (fase.richiedeNote) 'Note',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (fase.generaErp) const Chip(label: Text('Genera ERP'), avatar: Icon(Icons.receipt_long_outlined, size: 16)),
          ...requisiti.map((r) => Chip(label: Text(r))),
          if (requisiti.isEmpty && !fase.generaErp) const Chip(label: Text('Nessun dato obbligatorio')),
        ]),
        if (chiusura != null) ...[
          const SizedBox(height: 6),
          Text(
            chiusura!.generatoErp
                ? 'Chiusura gia registrata con effetto ERP: la modifica diretta e bloccata, serve rettifica controllata.'
                : 'Chiusura gia registrata: i campi sono precompilati e possono essere aggiornati.',
            style: TextStyle(fontWeight: FontWeight.w700, color: chiusura!.generatoErp ? const Color(0xFFB42318) : const Color(0xFF166534)),
          ),
        ],
      ]),
    );
  }
}
class _MonthScroller extends StatelessWidget {
  const _MonthScroller({required this.selectedMonth, required this.onSelected});
  final int selectedMonth;
  final ValueChanged<int> onSelected;
  static const labels = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(12, (i) { final month = i + 1; final selected = selectedMonth == month; return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(labels[i]), selected: selected, selectedColor: const Color(0xFFDCC7FF), labelStyle: TextStyle(fontWeight: FontWeight.w800, color: selected ? const Color(0xFF4A2D73) : null), onSelected: (_) => onSelected(month))); })));
}

class _AgendaCalendarGrid extends StatelessWidget {
  const _AgendaCalendarGrid({required this.mese, required this.selected, required this.counts, required this.onSelected});
  final DateTime mese;
  final DateTime selected;
  final Map<String, int> counts;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(mese.year, mese.month, 1);
    final days = DateTime(mese.year, mese.month + 1, 0).day;
    final offset = first.weekday - 1;
    final total = offset + days;
    final rows = (total / 7).ceil();
    final cells = rows * 7;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD9C8F0))),
      child: Column(children: [
        Row(children: ['Lun','Mar','Mer','Gio','Ven','Sab','Dom'].map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w800))))).toList()),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 0.86),
          itemBuilder: (context, index) {
            final dayNum = index - offset + 1;
            if (dayNum < 1 || dayNum > days) return const SizedBox.shrink();
            final date = DateTime(mese.year, mese.month, dayNum);
            final selectedDay = date.year == selected.year && date.month == selected.month && date.day == selected.day;
            final count = counts['${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'] ?? 0;
            final has = count > 0;
            return InkWell(
              onTap: () => onSelected(date),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selectedDay ? const Color(0xFFE9DAFF) : has ? const Color(0xFFF5EEFF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selectedDay ? const Color(0xFF6D3FB1) : has ? const Color(0xFFC9ABE8) : const Color(0xFFE1E6ED), width: selectedDay ? 1.6 : 1),
                ),
                child: Stack(children: [
                  Align(alignment: Alignment.topLeft, child: Text(dayNum.toString(), style: const TextStyle(fontWeight: FontWeight.w700))),
                  if (has) Align(alignment: Alignment.bottomRight, child: Container(width: 24, height: 24, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6D3FB1)), child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)))),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required this.row, required this.selected, required this.onTap});
  final AttivitaProduttiva row;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: selected ? const Color(0xFFE9DAFF) : Colors.white,
    child: ListTile(
      onTap: onTap,
      title: Text(row.codArticolo ?? 'Articolo da definire', style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${row.processoDescrizione ?? row.codProcesso ?? 'Processo -'}\nFase ${row.faseDescrizione ?? row.codFase ?? '-'} - ${row.stato}', maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: row.idDichiarazione == null ? const Icon(Icons.schedule_outlined) : const Icon(Icons.receipt_long_outlined, color: Color(0xFF16803C)),
    ),
  );
}

class _AgendaEmptyPanel extends StatelessWidget {
  const _AgendaEmptyPanel({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD9C8F0))),
    child: Row(children: [Icon(icon, color: const Color(0xFF6D3FB1)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF536273))))]),
  );
}








