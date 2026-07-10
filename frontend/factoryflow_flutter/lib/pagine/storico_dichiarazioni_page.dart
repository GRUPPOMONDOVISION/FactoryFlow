import 'package:flutter/material.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class StoricoDichiarazioniPage extends StatefulWidget {
  const StoricoDichiarazioniPage({super.key, required this.onNuovaDichiarazione});

  final ValueChanged<DateTime> onNuovaDichiarazione;

  @override
  State<StoricoDichiarazioniPage> createState() => _StoricoDichiarazioniPageState();
}

class _StoricoDichiarazioniPageState extends State<StoricoDichiarazioniPage> {
  final _service = ProduzioneService();
  final _lottoController = TextEditingController();
  final _magazzinoController = TextEditingController();
  final _quantitaController = TextEditingController();
  final _descrizioneController = TextEditingController();
  TimeOfDay? _oraInizioProduzione;
  TimeOfDay? _oraFineProduzione;

  DateTime _mese = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _giorno = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<DichiarazioneCalendarioGiorno> _calendario = [];
  List<DichiarazioneStorico> _dichiarazioniMese = [];
  List<LineaProduzione> _linee = [];
  List<MacchinaProduzione> _macchine = [];
  List<OperatoreProduzione> _operatori = [];
  List<RuoloOperativo> _ruoli = [];
  DichiarazioneStorico? _dettaglio;
  bool _loading = true;
  bool _loadingDetail = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  @override
  void dispose() {
    _lottoController.dispose();
    _magazzinoController.dispose();
    _quantitaController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    try {
      final dal = DateTime(_mese.year, _mese.month, 1);
      final al = DateTime(_mese.year, _mese.month + 1, 0);
      final calendario = await _service.getCalendarioDichiarazioni(dal, al);
      final dichiarazioni = await _service.getDichiarazioni(dal, al);
      final linee = await _service.getLinee(soloAttive: false);
      final operatori = await _service.getOperatori();
      final ruoli = await _service.getRuoliOperativi();
      final macchine = await _service.getMacchine();
      if (!mounted) return;
      setState(() {
        _calendario = calendario;
        _dichiarazioniMese = dichiarazioni;
        _linee = linee;
        _operatori = operatori;
        _ruoli = ruoli;
        _macchine = macchine;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Errore caricamento dichiarazioni: $e', isError: true);
    }
  }

  Future<void> _openDetail(DichiarazioneStorico row) async {
    setState(() => _loadingDetail = true);
    try {
      final dettaglio = await _service.getDichiarazione(row.idDichiarazione);
      await _loadLottiStorico(dettaglio);
      if (!mounted) return;
      setState(() {
        _dettaglio = dettaglio;
        _fillDetailControllers(dettaglio);
        _loadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
      _showMessage('Errore apertura dichiarazione: $e', isError: true);
    }
  }

  Future<void> _loadLottiStorico(DichiarazioneStorico dettaglio) async {
    for (final componente in dettaglio.componenti.where((c) => c.gestioneLotti)) {
      final lotti = await _service.getLotti(
        componente.codComponente,
        componente.magazzino,
        dettaglio.dataProduzione,
      );

      final currentLot = componente.lotto?.trim();
      if (currentLot != null && currentLot.isNotEmpty && !lotti.any((lotto) => lotto.codiceLotto == currentLot)) {
        componente.lotti = [
          LottoProduzione(codiceLotto: currentLot, disponibilita: 0, dataScadenza: null, magazzino: componente.magazzino),
          ...lotti,
        ];
      } else {
        componente.lotti = lotti;
      }
    }
  }
  void _fillDetailControllers(DichiarazioneStorico dettaglio) {
    _lottoController.text = dettaglio.lottoPF ?? '';
    _magazzinoController.text = dettaglio.magazzinoPF;
    _quantitaController.text = _fmtNum(dettaglio.quantitaProdotta);
    _descrizioneController.text = dettaglio.descrizionePF ?? '';
    _oraInizioProduzione = _timeFromDateTime(dettaglio.oraInizioProduzione);
    _oraFineProduzione = _timeFromDateTime(dettaglio.oraFineProduzione);
  }

  bool _applyDetailValues(DichiarazioneStorico dettaglio) {
    final qta = double.tryParse(_quantitaController.text.replaceAll(',', '.'));
    if (qta == null || qta <= 0) {
      _showMessage('Quantita prodotta non valida.', isError: true);
      return false;
    }

    if (_magazzinoController.text.trim().isEmpty) {
      _showMessage('Magazzino PF obbligatorio.', isError: true);
      return false;
    }

    if (_oraInizioProduzione == null || _oraFineProduzione == null) {
      _showMessage('Ora inizio e ora fine produzione sono obbligatorie.', isError: true);
      return false;
    }

    final inizio = _combineDateTime(dettaglio.dataProduzione, _oraInizioProduzione!);
    final fine = _combineDateTime(dettaglio.dataProduzione, _oraFineProduzione!);
    if (!fine.isAfter(inizio)) {
      _showMessage("Ora fine produzione deve essere successiva all'ora inizio.", isError: true);
      return false;
    }

    dettaglio.oraInizioProduzione = inizio;
    dettaglio.oraFineProduzione = fine;
    dettaglio.lottoPF = _lottoController.text.trim();
    dettaglio.magazzinoPF = _magazzinoController.text.trim();
    dettaglio.quantitaProdotta = qta;
    dettaglio.descrizionePF = _descrizioneController.text.trim();
    return true;
  }

  Future<void> _saveDetail() async {
    final dettaglio = _dettaglio;
    if (dettaglio == null) return;
    if (!_applyDetailValues(dettaglio)) return;

    setState(() => _saving = true);
    try {
      await _service.salvaDichiarazioneStorico(dettaglio);
      await _loadMonth();
      final updated = await _service.getDichiarazione(dettaglio.idDichiarazione);
      await _loadLottiStorico(updated);
      if (!mounted) return;
      setState(() {
        _dettaglio = updated;
        _fillDetailControllers(updated);
      });
      final adhocLinked = (updated.serialeCaricoAdhoc ?? '').trim().isNotEmpty || (updated.serialeScaricoAdhoc ?? '').trim().isNotEmpty;
      _showMessage(adhocLinked ? 'Dichiarazione aggiornata in FactoryFlow e AdHoc.' : 'Dichiarazione prevista aggiornata in FactoryFlow.');
    } catch (e) {
      _showMessage('Errore salvataggio dichiarazione: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  TimeOfDay? _timeFromDateTime(DateTime? value) {
    if (value == null) return null;
    return TimeOfDay(hour: value.hour, minute: value.minute);
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
  Future<void> _annullaDetail() async {
    final dettaglio = _dettaglio;
    if (dettaglio == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancella dichiarazione'),
        content: const Text('La cancellazione aggiorna FactoryFlow e allinea i documenti AdHoc collegati con ricalcolo dei saldi lotto.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Annulla')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await _service.annullaDichiarazioneStorico(dettaglio.idDichiarazione);
      await _loadMonth();
      final updated = await _service.getDichiarazione(dettaglio.idDichiarazione);
      if (!mounted) return;
      setState(() {
        _dettaglio = updated;
        _fillDetailControllers(updated);
      });
      _showMessage('Dichiarazione cancellata in FactoryFlow e AdHoc.');
    } catch (e) {
      _showMessage('Errore annullamento dichiarazione: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  Future<void> _confermaPrevista() async {
    final dettaglio = _dettaglio;
    if (dettaglio == null) return;
    if (!_applyDetailValues(dettaglio)) return;

    setState(() => _saving = true);
    try {
      await _service.salvaDichiarazioneStorico(dettaglio);
      final message = await _service.confermaDichiarazionePrevista(dettaglio.idDichiarazione);
      await _loadMonth();
      final updated = await _service.getDichiarazione(dettaglio.idDichiarazione);
      await _loadLottiStorico(updated);
      if (!mounted) return;
      setState(() {
        _dettaglio = updated;
        _fillDetailControllers(updated);
      });
      _showMessage(message);
    } catch (e) {
      _showMessage('Errore conferma dichiarazione prevista: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  void _changeYear(int delta) {
    setState(() {
      _mese = DateTime(_mese.year + delta, _mese.month);
      _giorno = DateTime(_mese.year, _mese.month, 1);
      _dettaglio = null;
    });
    _loadMonth();
  }

  void _selectMonth(int month) {
    setState(() {
      _mese = DateTime(_mese.year, month);
      _giorno = DateTime(_mese.year, month, 1);
      _dettaglio = null;
    });
    _loadMonth();
  }

  List<DichiarazioneStorico> get _dichiarazioniGiorno {
    return _dichiarazioniMese.where((d) => _sameDay(d.dataProduzione, _giorno)).toList();
  }

  Map<String, int> get _conteggi {
    return {for (final row in _calendario) _dateKey(row.dataProduzione): row.numeroDichiarazioni};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery.sizeOf(context).width >= 700) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => widget.onNuovaDichiarazione(_giorno),
            tooltip: 'Nuova dichiarazione',
            child: const Icon(Icons.add),
          );
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1000;
                final mobile = constraints.maxWidth < 700;
                final master = _buildMaster(mobile: mobile);
                final detail = _buildDetail(mobile: mobile);
                if (desktop) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox.expand(child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 480, child: SingleChildScrollView(child: master)),
                        const SizedBox(width: 16),
                        Expanded(child: SingleChildScrollView(child: detail)),
                      ],
                    )),
                  );
                }
                return ListView(
                  padding: EdgeInsets.all(mobile ? 12 : 16),
                  children: [master, const SizedBox(height: 16), detail],
                );
              },
            ),
    );
  }

  Widget _buildMaster({required bool mobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(onPressed: () => _changeYear(-1), icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                'Esercizio ${_mese.year}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton.filledTonal(onPressed: () => _changeYear(1), icon: const Icon(Icons.chevron_right)),
            if (!mobile) ...[
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: () => widget.onNuovaDichiarazione(_giorno), icon: const Icon(Icons.add), label: const Text('Nuova')),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _MonthScroller(selectedMonth: _mese.month, onSelected: _selectMonth),
        const SizedBox(height: 12),
        Text(_monthLabel(_mese), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _CalendarGrid(
          mese: _mese,
          selected: _giorno,
          counts: _conteggi,
          onSelected: (date) => setState(() {
            _giorno = date;
            _dettaglio = null;
          }),
        ),
        const SizedBox(height: 16),
        Text('Dichiarazioni del ${_fmtDate(_giorno)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (_dichiarazioniGiorno.isEmpty)
          const _EmptyPanel(icon: Icons.event_busy_outlined, text: 'Nessuna dichiarazione in questa data.')
        else
          ..._dichiarazioniGiorno.map((row) => _DichiarazioneTile(row: row, selected: _dettaglio?.idDichiarazione == row.idDichiarazione, onTap: () => _openDetail(row))),
      ],
    );
  }

  Widget _buildDetail({required bool mobile}) {
    final dettaglio = _dettaglio;
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    if (dettaglio == null) return const _EmptyPanel(icon: Icons.touch_app_outlined, text: 'Selezionare una dichiarazione dal calendario.');

    final annullata = dettaglio.stato == 'ANNULLATA';
    final prevista = dettaglio.stato == 'PREVISTA' && (dettaglio.serialeCaricoAdhoc ?? '').trim().isEmpty && (dettaglio.serialeScaricoAdhoc ?? '').trim().isEmpty;
    final confermabileOggi = prevista && _sameDay(dettaglio.dataProduzione, DateTime.now());
    final produttivitaAnomala = _produttivitaAnomala(dettaglio);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${dettaglio.codArticoloPF} - ${dettaglio.descrizionePF ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(text: dettaglio.stato, color: _statusColor(dettaglio.stato), background: _statusBackground(dettaglio.stato)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Carico ${dettaglio.serialeCaricoAdhoc ?? '-'} / ${dettaglio.numeroCaricoAdhoc ?? '-'}   Scarico ${dettaglio.serialeScaricoAdhoc ?? '-'} / ${dettaglio.numeroScaricoAdhoc ?? '-'}'),
          const SizedBox(height: 14),
          _InfoBanner(text: prevista ? 'Registrazione prevista: le modifiche restano in FactoryFlow finche non viene confermata nel giorno previsto.' : 'Le modifiche aggiornano lo storico FactoryFlow e i documenti AdHoc collegati tramite seriale.'),
          const SizedBox(height: 14),
          _ResponsiveFields(
            mobile: mobile,
            children: [
              DropdownButtonFormField<int?>(
                initialValue: dettaglio.idLinea,
                decoration: const InputDecoration(labelText: 'Linea'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Nessuna linea')),
                  ..._linee.map((linea) => DropdownMenuItem<int?>(value: linea.idLinea, child: Text(linea.label, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: annullata || _saving ? null : (value) => setState(() => dettaglio.idLinea = value),
              ),
              DropdownButtonFormField<int?>( 
                initialValue: dettaglio.idMacchina,
                decoration: const InputDecoration(labelText: 'Macchina / risorsa'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Nessuna macchina')),
                  ..._macchine
                      .where((macchina) => dettaglio.idLinea == null || macchina.idLinea == null || macchina.idLinea == dettaglio.idLinea)
                      .map((macchina) => DropdownMenuItem<int?>(value: macchina.idMacchina, child: Text(macchina.label, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: annullata || _saving ? null : (value) => setState(() => dettaglio.idMacchina = value),
              ),
              _DateField(
                value: dettaglio.dataProduzione,
                enabled: !annullata && !_saving,
                onChanged: (value) => setState(() => dettaglio.dataProduzione = value),
              ),
              _TimeField(
                label: 'Ora inizio',
                value: _oraInizioProduzione,
                enabled: !annullata && !_saving,
                onChanged: (value) => setState(() => _oraInizioProduzione = value),
              ),
              _TimeField(
                label: 'Ora fine',
                value: _oraFineProduzione,
                enabled: !annullata && !_saving,
                onChanged: (value) => setState(() => _oraFineProduzione = value),
              ),
              TextField(controller: _quantitaController, enabled: !annullata && !_saving, keyboardType: TextInputType.number, style: TextStyle(color: produttivitaAnomala ? const Color(0xFFB42318) : null, fontWeight: produttivitaAnomala ? FontWeight.w800 : null), decoration: const InputDecoration(labelText: 'Quantita prodotta')),
              TextField(controller: _magazzinoController, enabled: !annullata && !_saving, decoration: const InputDecoration(labelText: 'Magazzino PF')),
              TextField(controller: _lottoController, enabled: !annullata && !_saving, decoration: const InputDecoration(labelText: 'Lotto PF')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _descrizioneController, enabled: !annullata && !_saving, decoration: const InputDecoration(labelText: 'Descrizione snapshot')),
          const SizedBox(height: 18),
          _TeamStoricoSection(
            operatori: _operatori,
            ruoli: _ruoli,
            righe: dettaglio.operatori,
            enabled: !annullata && !_saving,
            dataProduzione: dettaglio.dataProduzione,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 18),
          Text('Componenti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...dettaglio.componenti.map((componente) => _ComponenteStoricoRow(componente: componente, enabled: !annullata && !_saving)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(onPressed: annullata || _saving ? null : _annullaDetail, icon: const Icon(Icons.delete_outline), label: const Text('Cancella')),
              if (prevista)
                FilledButton.icon(onPressed: !confermabileOggi || _saving ? null : _confermaPrevista, icon: const Icon(Icons.fact_check_outlined), label: const Text('Conferma produzione')),
              FilledButton.icon(onPressed: annullata || _saving ? null : _saveDetail, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined), label: const Text('Salva')),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: isError ? const Color(0xFFB42318) : const Color(0xFF16803C)));
  }

  BoxDecoration _panelDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5)));
}

class _TeamStoricoSection extends StatelessWidget {
  const _TeamStoricoSection({required this.operatori, required this.ruoli, required this.righe, required this.enabled, required this.dataProduzione, required this.onChanged});

  final List<OperatoreProduzione> operatori;
  final List<RuoloOperativo> ruoli;
  final List<DichiarazioneOperatore> righe;
  final bool enabled;
  final DateTime dataProduzione;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.groups_outlined, color: Color(0xFF2D465C)),
          const SizedBox(width: 8),
          Expanded(child: Text('Team operativo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          OutlinedButton.icon(onPressed: !enabled ? null : () { righe.add(DichiarazioneOperatore()); onChanged(); }, icon: const Icon(Icons.add), label: const Text('Operatore')),
        ]),
        const SizedBox(height: 10),
        if (righe.isEmpty) const Text('Nessun operatore associato alla dichiarazione.') else ...List.generate(righe.length, (index) => _TeamStoricoRow(row: righe[index], operatori: operatori, ruoli: ruoli, enabled: enabled, dataProduzione: dataProduzione, onRemove: () { righe.removeAt(index); onChanged(); }, onChanged: onChanged)),
      ]),
    );
  }
}

class _TeamStoricoRow extends StatelessWidget {
  const _TeamStoricoRow({required this.row, required this.operatori, required this.ruoli, required this.enabled, required this.dataProduzione, required this.onRemove, required this.onChanged});

  final DichiarazioneOperatore row;
  final List<OperatoreProduzione> operatori;
  final List<RuoloOperativo> ruoli;
  final bool enabled;
  final DateTime dataProduzione;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(width: 260, child: DropdownButtonFormField<int>(initialValue: row.idOperatore, isExpanded: true, decoration: const InputDecoration(labelText: 'Operatore'), items: operatori.map((o) => DropdownMenuItem<int>(value: o.idOperatore, child: Text(o.label, overflow: TextOverflow.ellipsis))).toList(), onChanged: !enabled ? null : (value) { final selected = operatori.where((o) => o.idOperatore == value).firstOrNull; row.idOperatore = value; row.codOperatoreSnapshot = selected?.codOperatore; row.nomeOperatoreSnapshot = selected == null ? null : [selected.nome, selected.cognome].where((e) => e != null && e.trim().isNotEmpty).join(' '); row.costoOrarioApplicato ??= selected?.costoOrarioRiferimento; onChanged(); })),
        SizedBox(width: 220, child: DropdownButtonFormField<int>(initialValue: row.idRuoloOperativo, isExpanded: true, decoration: const InputDecoration(labelText: 'Ruolo'), items: ruoli.map((r) => DropdownMenuItem<int>(value: r.idRuoloOperativo, child: Text(r.label, overflow: TextOverflow.ellipsis))).toList(), onChanged: !enabled ? null : (value) { final selected = ruoli.where((r) => r.idRuoloOperativo == value).firstOrNull; row.idRuoloOperativo = value; row.ruoloSnapshot = selected?.descrizione; onChanged(); })),
        _TeamTime(label: 'Inizio', value: row.oraInizio, enabled: enabled, dataProduzione: dataProduzione, onChanged: (v) { row.oraInizio = v; onChanged(); }),
        _TeamTime(label: 'Fine', value: row.oraFine, enabled: enabled, dataProduzione: dataProduzione, onChanged: (v) { row.oraFine = v; onChanged(); }),
        SizedBox(width: 150, child: TextFormField(initialValue: row.costoOrarioApplicato?.toString() ?? '', enabled: enabled, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Costo/h'), onChanged: (v) { row.costoOrarioApplicato = double.tryParse(v.replaceAll(',', '.')); })),
        SizedBox(width: 250, child: TextFormField(initialValue: row.note, enabled: enabled, decoration: const InputDecoration(labelText: 'Note'), onChanged: (v) => row.note = v)),
        IconButton.outlined(onPressed: enabled ? onRemove : null, icon: const Icon(Icons.delete_outline)),
      ]),
    );
  }
}

class _TeamTime extends StatelessWidget {
  const _TeamTime({required this.label, required this.value, required this.enabled, required this.dataProduzione, required this.onChanged});
  final String label;
  final DateTime? value;
  final bool enabled;
  final DateTime dataProduzione;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '-' : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
    return SizedBox(width: 120, height: 48, child: OutlinedButton.icon(onPressed: !enabled ? null : () async { final picked = await showTimePicker(context: context, initialTime: value == null ? TimeOfDay.now() : TimeOfDay(hour: value!.hour, minute: value!.minute)); if (picked != null) onChanged(DateTime(dataProduzione.year, dataProduzione.month, dataProduzione.day, picked.hour, picked.minute)); }, icon: const Icon(Icons.schedule_outlined, size: 16), label: FittedBox(child: Text('$label $text'))));
  }
}
class _MonthScroller extends StatelessWidget {
  const _MonthScroller({required this.selectedMonth, required this.onSelected});

  final int selectedMonth;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = index + 1;
          final selected = month == selectedMonth;
          return ChoiceChip(
            selected: selected,
            label: Text(_shortMonthLabel(month)),
            onSelected: (_) => onSelected(month),
            labelStyle: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF344054)),
            selectedColor: const Color(0xFF2F6EA3),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFD7DDE5))),
          );
        },
      ),
    );
  }
}
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.mese, required this.selected, required this.counts, required this.onSelected});

  final DateTime mese;
  final DateTime selected;
  final Map<String, int> counts;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(mese.year, mese.month, 1);
    final daysInMonth = DateTime(mese.year, mese.month + 1, 0).day;
    final leading = first.weekday - 1;
    final cells = List<DateTime?>.of(List<DateTime?>.filled(leading, null), growable: true);
    cells.addAll(List.generate(daysInMonth, (i) => DateTime(mese.year, mese.month, i + 1)));
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: Center(child: Text('Lun', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Mar', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Mer', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Gio', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Ven', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Sab', style: TextStyle(fontWeight: FontWeight.w800)))),
              Expanded(child: Center(child: Text('Dom', style: TextStyle(fontWeight: FontWeight.w800)))),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 0.78),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final date = cells[index];
              if (date == null) return const SizedBox.shrink();
              final count = counts[_dateKey(date)] ?? 0;
              final active = _sameDay(date, selected);
              return InkWell(
                onTap: () => onSelected(date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: active ? const Color(0xFFEAF2FB) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? const Color(0xFF2F6EA3) : const Color(0xFFE1E5EA))),
                  child: Stack(children: [Align(alignment: Alignment.topLeft, child: Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.w800))), if (count > 0) Align(alignment: Alignment.bottomRight, child: _CountBadge(count: count))]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DichiarazioneTile extends StatelessWidget {
  const _DichiarazioneTile({required this.row, required this.selected, required this.onTap});

  final DichiarazioneStorico row;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final linea = row.codLinea == null || row.codLinea!.isEmpty ? 'Nessuna linea' : '${row.codLinea} - ${row.nomeLinea ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFFEAF2FB) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFD7DDE5))),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(row.codArticoloPF, style: const TextStyle(fontWeight: FontWeight.w800))),
                    const SizedBox(width: 8),
                    _StatusBadge(text: row.stato, color: _statusColor(row.stato), background: _statusBackground(row.stato)),
                  ],
                ),
                const SizedBox(height: 5),
                Text('Linea $linea', style: const TextStyle(color: Color(0xFF475467), fontWeight: FontWeight.w700)),
                Text(row.descrizionePF ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF475467))),
                const SizedBox(height: 3),
                Text('Qta ${_fmtNum(row.quantitaProdotta)} - Lotto ${row.lottoPF ?? '-'}', style: TextStyle(color: _produttivitaAnomala(row) ? const Color(0xFFB42318) : const Color(0xFF475467), fontWeight: _produttivitaAnomala(row) ? FontWeight.w800 : FontWeight.normal)),
                Text('Ora ${_fmtTimeRange(row.oraInizioProduzione, row.oraFineProduzione)}${row.produttivitaMinuto == null ? '' : ' - ${_fmtRate(row.produttivitaMinuto!)} pz/min'}', style: const TextStyle(color: Color(0xFF475467))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.enabled, required this.onChanged});

  final DateTime value;
  final bool enabled;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Data produzione'),
        child: Text(_fmtDate(value)),
      ),
    );
  }
}
class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, required this.enabled, required this.onChanged});

  final String label;
  final TimeOfDay? value;
  final bool enabled;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: value ?? const TimeOfDay(hour: 8, minute: 0),
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value == null ? '-' : _fmtTime(value!)),
      ),
    );
  }
}
class _ComponenteStoricoRow extends StatelessWidget {
  const _ComponenteStoricoRow({required this.componente, required this.enabled});

  final DichiarazioneStoricoComponente componente;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selectedLot = componente.lotti.where((lotto) => lotto.codiceLotto == componente.lotto).firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E5EA))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(componente.codComponente, style: const TextStyle(fontWeight: FontWeight.w800))),
            if (componente.gestioneLotti) const _StatusBadge(text: 'LOTTO', color: Color(0xFF174A7C), background: Color(0xFFEAF2FB)),
          ],
        ),
        Text(componente.descrizioneComponente ?? ''),
        if (selectedLot != null) ...[
          const SizedBox(height: 4),
          Text('Disponibilita ${_fmtNum(selectedLot.disponibilita)} - Scadenza ${selectedLot.dataScadenza == null ? '-' : _fmtDate(selectedLot.dataScadenza!)}', style: const TextStyle(color: Color(0xFF475467), fontSize: 12, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 8),
        _ResponsiveFields(mobile: MediaQuery.sizeOf(context).width < 700, wideIndex: componente.gestioneLotti ? 1 : null, children: [
          TextFormField(initialValue: _fmtNum(componente.quantitaEffettiva), enabled: enabled, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Effettiva'), onChanged: (v) => componente.quantitaEffettiva = double.tryParse(v.replaceAll(',', '.')) ?? componente.quantitaEffettiva),
          if (componente.gestioneLotti)
            DropdownButtonFormField<String>(
              initialValue: componente.lotto == null || componente.lotto!.isEmpty ? null : componente.lotto,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Lotto'),
              items: componente.lotti
                  .map((lotto) => DropdownMenuItem<String>(
                        value: lotto.codiceLotto,
                        child: Text('${lotto.codiceLotto} - disp. ${_fmtNum(lotto.disponibilita)}${lotto.dataScadenza == null ? '' : ' - scad. ${_fmtDate(lotto.dataScadenza!)}'}', overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: enabled ? (value) => componente.lotto = value : null,
            ),
          TextFormField(initialValue: componente.magazzino, enabled: enabled, decoration: const InputDecoration(labelText: 'Magazzino'), onChanged: (v) => componente.magazzino = v.trim()),
        ]),
      ]),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.mobile, required this.children, this.wideIndex = 0});

  final bool mobile;
  final List<Widget> children;
  final int? wideIndex;

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Column(children: children.map((child) => Padding(padding: const EdgeInsets.only(bottom: 10), child: child)).toList());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final lineWidth = available >= 900 ? 360.0 : 300.0;
        final fieldWidth = available >= 900 ? 220.0 : 190.0;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var index = 0; index < children.length; index++)
              SizedBox(
                width: index == wideIndex ? lineWidth.clamp(260.0, available) : fieldWidth.clamp(170.0, available),
                child: children[index],
              ),
          ],
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF2F6EA3), borderRadius: BorderRadius.circular(999)), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)));
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color, required this.background});
  final String text;
  final Color color;
  final Color background;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)), child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)));
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF6D58A))), child: Text(text, style: const TextStyle(color: Color(0xFF704B00), fontWeight: FontWeight.w700)));
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))), child: Row(children: [Icon(icon, color: const Color(0xFF667085)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475467))))]));
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
bool _produttivitaAnomala(DichiarazioneStorico row) => row.scostamentoProduttivitaPercentuale != null && row.scostamentoProduttivitaPercentuale!.abs() >= 20;
String _fmtTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
String _fmtDateTimeTime(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
String _fmtTimeRange(DateTime? start, DateTime? end) => start == null || end == null ? '-' : '${_fmtDateTimeTime(start)}-${_fmtDateTimeTime(end)}';
String _fmtDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String _fmtNum(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(3);
String _fmtRate(double value) => value.toStringAsFixed(2).replaceAll('.', ',');
Color _statusColor(String stato) => switch (stato) {
  'ANNULLATA' => const Color(0xFFB42318),
  'PREVISTA' => const Color(0xFF8A5A00),
  _ => const Color(0xFF16803C),
};
Color _statusBackground(String stato) => switch (stato) {
  'ANNULLATA' => const Color(0xFFFFE4E2),
  'PREVISTA' => const Color(0xFFFFF3D6),
  _ => const Color(0xFFE7F8EE),
};
String _shortMonthLabel(int month) {
  const months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
  return months[month - 1];
}

String _monthLabel(DateTime date) {
  const months = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
  return '${months[date.month - 1]} ${date.year}';
}



































