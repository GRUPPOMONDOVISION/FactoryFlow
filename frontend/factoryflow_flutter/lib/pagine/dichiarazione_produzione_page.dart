import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart';
import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';
import 'linee_produzione_page.dart';

class DichiarazioneProduzionePage extends StatefulWidget {
  const DichiarazioneProduzionePage({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<DichiarazioneProduzionePage> createState() => _DichiarazioneProduzionePageState();
}

enum LayoutSize { desktop, tablet, mobile }

enum _MessageKind { info, success, error }

class _DichiarazioneProduzionePageState extends State<DichiarazioneProduzionePage> {
  final _service = ProduzioneService();
  final _quantitaController = TextEditingController(text: '1');
  final _lottoFinitoController = TextEditingController();
  final _magazzinoController = TextEditingController(text: AppConfig.magazzinoDefault);
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  List<LineaProduzione> _linee = [];
  LineaProduzione? _linea;
  List<MacchinaProduzione> _macchine = [];
  MacchinaProduzione? _macchina;
  List<ArticoloProduzione> _articoli = [];
  ArticoloProduzione? _articolo;
  late DateTime _dataProduzione;
  TimeOfDay? _oraInizioProduzione;
  TimeOfDay? _oraFineProduzione;
  List<ComponenteDistinta> _componenti = [];
  List<OperatoreProduzione> _operatori = [];
  List<RuoloOperativo> _ruoliOperativi = [];
  List<TeamOperativo> _teamDisponibili = [];
  int? _teamSelezionato;
  final List<DichiarazioneOperatore> _teamOperativo = [];
  ProduttivitaArticolo? _produttivitaArticolo;
  bool _loadingProduttivita = false;
  Timer? _debounce;
  int _distintaRequestId = 0;
  bool _loadingLinee = true;
  bool _loadingArticoli = false;
  bool _loadingDistinta = false;
  bool _saving = false;
  String? _message;
  _MessageKind _messageKind = _MessageKind.info;

  @override
  void initState() {
    super.initState();
    _dataProduzione = widget.initialDate ?? DateTime.now();
    _loadLinee();
    _loadTeamOperativoBase();
    _quantitaController.addListener(_onQuantitaChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _quantitaController.dispose();
    _lottoFinitoController.dispose();
    _magazzinoController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  bool get _canConfirm => !_saving && !_loadingLinee && !_loadingDistinta && _componenti.isNotEmpty;

  Future<void> _loadLinee() async {
    try {
      final result = await _service.getLinee();
      if (!mounted) {
        return;
      }

      setState(() {
        _linee = result;
        _loadingLinee = false;
        _linea = null;
        _articoli = [];
        _articolo = null;
        _componenti = [];
        if (result.isEmpty) {
          _message = 'Nessuna linea configurata. Configurare almeno una linea di produzione.';
          _messageKind = _MessageKind.error;
        } else {
          _message = 'Selezionare una linea di produzione.';
          _messageKind = _MessageKind.info;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _loadingLinee = false);
      _showError('Errore backend durante il caricamento linee: $e');
    }
  }

  Future<void> _loadArticoli() async {
    final linea = _linea;
    if (linea == null) {
      setState(() {
        _articoli = [];
        _articolo = null;
        _componenti = [];
      });
      return;
    }

    setState(() {
      _loadingArticoli = true;
      _articoli = [];
      _articolo = null;
      _componenti = [];
      _message = 'Caricamento articoli associati alla linea...';
      _messageKind = _MessageKind.info;
    });

    try {
      final result = await _service.getArticoliLinea(linea.idLinea);
      if (!mounted) {
        return;
      }

      setState(() {
        _articoli = result;
        _loadingArticoli = false;
        if (result.isEmpty) {
          _message = 'Nessun articolo associato alla linea selezionata.';
          _messageKind = _MessageKind.info;
        } else {
          _message = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _loadingArticoli = false);
      _showError('Errore backend durante il caricamento articoli linea: $e');
    }
  }
  Future<void> _loadTeamOperativoBase() async {
    try {
      final results = await Future.wait([
        _service.getOperatori(),
        _service.getRuoliOperativi(),
        _service.getTeamOperativi(),
        _service.getMacchine(),
      ]);
      if (!mounted) return;
      setState(() {
        _operatori = results[0] as List<OperatoreProduzione>;
        _ruoliOperativi = results[1] as List<RuoloOperativo>;
        _teamDisponibili = results[2] as List<TeamOperativo>;
        _macchine = results[3] as List<MacchinaProduzione>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _operatori = [];
        _ruoliOperativi = [];
        _teamDisponibili = [];
        _macchine = [];
      });
    }
  }

  Future<void> _applicaTeamOperativo(int? idTeam) async {
    setState(() => _teamSelezionato = idTeam);
    if (idTeam == null) return;
    try {
      final rows = await _service.getTeamOperatori(idTeam);
      if (!mounted) return;
      setState(() {
        _teamOperativo
          ..clear()
          ..addAll(rows.where((r) => r.attivo).map((r) => DichiarazioneOperatore(
                idOperatore: r.idOperatore,
                idRuoloOperativo: r.idRuoloOperativo,
                codOperatoreSnapshot: r.codOperatore,
                nomeOperatoreSnapshot: r.nomeCompleto,
                ruoloSnapshot: r.ruoloDescrizione,
                oraInizio: _oraInizioProduzione == null ? null : _combineDateTime(_oraInizioProduzione!),
                oraFine: _oraFineProduzione == null ? null : _combineDateTime(_oraFineProduzione!),
                costoOrarioApplicato: r.costoOrarioApplicato,
                note: r.note,
              )));
      });
    } catch (e) {
      _showError('Errore caricamento team operativo: ');
    }
  }

  void _addTeamOperatore() {
    setState(() {
      _teamOperativo.add(DichiarazioneOperatore(
        oraInizio: _oraInizioProduzione == null ? null : _combineDateTime(_oraInizioProduzione!),
        oraFine: _oraFineProduzione == null ? null : _combineDateTime(_oraFineProduzione!),
      ));
    });
  }

  void _removeTeamOperatore(int index) {
    setState(() => _teamOperativo.removeAt(index));
  }

  DateTime? _teamDateTime(TimeOfDay? value) {
    return value == null ? null : _combineDateTime(value);
  }

  TimeOfDay? _timeFromDateTime(DateTime? value) {
    if (value == null) return null;
    return TimeOfDay(hour: value.hour, minute: value.minute);
  }
  void _onQuantitaChanged() {
    if (mounted) setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _loadDistinta);
  }

  Future<void> _loadProduttivitaArticolo() async {
    final articolo = _articolo;
    if (articolo == null) {
      setState(() {
        _produttivitaArticolo = null;
        _loadingProduttivita = false;
      });
      return;
    }

    setState(() => _loadingProduttivita = true);
    try {
      final result = await _service.getProduttivitaArticolo(articolo.codArticolo, _linea?.idLinea);
      if (!mounted) return;
      setState(() {
        _produttivitaArticolo = result;
        _loadingProduttivita = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _produttivitaArticolo = null;
        _loadingProduttivita = false;
      });
    }
  }

  Future<void> _loadDistinta() async {
    final articolo = _articolo;
    final quantita = _parseDouble(_quantitaController.text);
    final requestId = ++_distintaRequestId;

    if (articolo == null || quantita <= 0) {
      setState(() {
        _componenti = [];
        if (articolo == null) _produttivitaArticolo = null;
      });
      return;
    }

    unawaited(_loadProduttivitaArticolo());

    setState(() {
      _loadingDistinta = true;
      _message = 'Caricamento distinta e lotti componenti...';
      _messageKind = _MessageKind.info;
    });

    try {
      final distinta = await _service.getDistinta(articolo.codArticolo, quantita);
      final componenti = distinta.componenti;
      for (final componente in componenti) {
        componente.quantitaDaScaricare = componente.quantitaProposta;
      }

      for (final componente in componenti.where((e) => e.gestioneLotti)) {
        componente.lotti = await _service.getLotti(
          componente.codComponente,
          componente.magazzino,
          _dataProduzione,
        );

        if (componente.lotti.isNotEmpty) {
          componente.lotto = componente.lotti.first.codiceLotto;
        }
      }

      if (!mounted || requestId != _distintaRequestId) {
        return;
      }

      setState(() {
        _componenti = componenti;
        _loadingDistinta = false;
        if (componenti.isEmpty) {
          _message = 'Nessun componente trovato per la distinta selezionata.';
          _messageKind = _MessageKind.info;
        } else {
          _message = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _componenti = [];
        _loadingDistinta = false;
      });
      _showError('Errore backend durante il caricamento distinta: $e');
    }
  }

  Future<void> _selectData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataProduzione,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() => _dataProduzione = picked);
    await _loadDistinta();
  }

  Future<void> _selectOraInizio() async {
    final picked = await showTimePicker(context: context, initialTime: _oraInizioProduzione ?? TimeOfDay.now());
    if (picked != null) {
      setState(() => _oraInizioProduzione = picked);
    }
  }

  Future<void> _selectOraFine() async {
    final picked = await showTimePicker(context: context, initialTime: _oraFineProduzione ?? _oraInizioProduzione ?? TimeOfDay.now());
    if (picked != null) {
      setState(() => _oraFineProduzione = picked);
    }
  }

  DateTime _combineDateTime(TimeOfDay time) {
    return DateTime(_dataProduzione.year, _dataProduzione.month, _dataProduzione.day, time.hour, time.minute);
  }

  void _aggiornaCostiTeam() {
    for (final riga in _teamOperativo) {
      if (riga.costoOrarioApplicato == null || riga.oraInizio == null || riga.oraFine == null || !riga.oraFine!.isAfter(riga.oraInizio!)) {
        riga.costoTotale = null;
        continue;
      }

      final ore = riga.oraFine!.difference(riga.oraInizio!).inMinutes / 60.0;
      riga.costoTotale = ore * riga.costoOrarioApplicato!;
    }
  }

  Future<void> _conferma() async {
    final articolo = _articolo;
    final quantita = _parseDouble(_quantitaController.text);

    if (_linea == null) {
      _showError('Selezionare una linea di produzione.');
      return;
    }

    if (articolo == null) {
      _showError('Selezionare un articolo producibile.');
      return;
    }

    if (quantita <= 0) {
      _showError('Quantita prodotta non valida.');
      return;
    }

    if (_oraInizioProduzione == null || _oraFineProduzione == null) {
      _showError('Ora inizio e ora fine produzione sono obbligatorie.');
      return;
    }

    if (!_combineDateTime(_oraFineProduzione!).isAfter(_combineDateTime(_oraInizioProduzione!))) {
      _showError("Ora fine produzione deve essere successiva all'ora inizio.");
      return;
    }

    if (_lottoFinitoController.text.trim().isEmpty) {
      _showError('Inserire il lotto del prodotto finito.');
      return;
    }

    for (final componente in _componenti.where((e) => e.gestioneLotti)) {
      if (componente.lotto == null || componente.lotto!.trim().isEmpty) {
        _showError('Selezionare il lotto per ${componente.codComponente}.');
        return;
      }
    }

    _aggiornaCostiTeam();

    setState(() {
      _saving = true;
      _message = _isFutureDate(_dataProduzione) ? 'Salvataggio previsione produzione in corso...' : 'Conferma produzione in corso...';
      _messageKind = _MessageKind.info;
    });

    try {
      final message = await _service.confermaDichiarazione(
        idLinea: _linea?.idLinea,
        idMacchina: _macchina?.idMacchina,
        articoloProdotto: articolo.codArticolo,
        descrizioneProdotto: articolo.descrizione,
        quantitaProdotta: quantita,
        dataProduzione: _dataProduzione,
        oraInizioProduzione: _combineDateTime(_oraInizioProduzione!),
        oraFineProduzione: _combineDateTime(_oraFineProduzione!),
        lottoProdotto: _lottoFinitoController.text,
        magazzinoProdotto: _magazzinoController.text,
        componenti: _componenti,
        operatori: _teamOperativo,
      );

      if (!mounted) return;
      setState(() {
        _message = 'Conferma riuscita. $message';
        _messageKind = _MessageKind.success;
        _saving = false;
      });
      _showSnack(_isFutureDate(_dataProduzione) ? 'Previsione salvata.' : 'Produzione registrata.', _MessageKind.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Errore backend durante la conferma: $e');
    }
  }
  void _showError(String message) {
    setState(() {
      _message = message;
      _messageKind = _MessageKind.error;
    });
    _showSnack(message, _MessageKind.error);
  }

  void _showSnack(String message, _MessageKind kind) {
    final colors = _messageColors(kind);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: colors.fg,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = layoutFor(constraints.maxWidth);
        final pagePadding = layout == LayoutSize.mobile ? 10.0 : 16.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('FactoryFlow - Dichiarazione Produzione'),
            actions: [
              IconButton(
                tooltip: 'Linee di produzione',
                icon: const Icon(Icons.precision_manufacturing_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LineeProduzionePage()));
                  if (mounted) {
                    await _loadLinee();
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderProduzione(
                  layout: layout,
                  lineaField: _buildLineaDropdown(),
                  macchinaField: _buildMacchinaDropdown(),
                  articoloField: _buildArticoloAutocomplete(),
                  quantitaController: _quantitaController,
                  magazzinoController: _magazzinoController,
                  lottoFinitoController: _lottoFinitoController,
                  dataLabel: _dateFormat.format(_dataProduzione),
                  oraInizioLabel: _formatTimeNullable(_oraInizioProduzione),
                  oraFineLabel: _formatTimeNullable(_oraFineProduzione),
                  saving: _saving,
                  canConfirm: _canConfirm,
                  onDatePressed: _selectData,
                  onOraInizioPressed: _selectOraInizio,
                  onOraFinePressed: _selectOraFine,
                  onConfirmPressed: _conferma,
                  onMagazzinoSubmitted: _loadDistinta,
                  confirmLabel: _isFutureDate(_dataProduzione) ? 'SALVA PREVISIONE' : 'CONFERMA PRODUZIONE',
                  savingLabel: _isFutureDate(_dataProduzione) ? 'SALVATAGGIO...' : 'CONFERMA...',
                ),
                if (_buildProduttivitaPanel(layout) case final panel?) ...[
                  SizedBox(height: layout == LayoutSize.mobile ? 8 : 10),
                  panel,
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD7DDE5))),
                  child: DropdownButtonFormField<int?>( 
                    initialValue: _teamSelezionato,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Seleziona team operativo', prefixIcon: Icon(Icons.groups_outlined)),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Nessun team predefinito')),
                      ..._teamDisponibili.where((t) => t.attivo).map((t) => DropdownMenuItem<int?>(value: t.idTeam, child: Text(t.label, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: _saving ? null : _applicaTeamOperativo,
                  ),
                ),
                const SizedBox(height: 10),
                TeamOperativoSection(
                  operatori: _operatori,
                  ruoli: _ruoliOperativi,
                  righe: _teamOperativo,
                  dataProduzione: _dataProduzione,
                  enabled: !_saving,
                  onAdd: _addTeamOperatore,
                  onRemove: _removeTeamOperatore,
                  onChanged: () => setState(() {}),
                  teamDateTime: _teamDateTime,
                  timeFromDateTime: _timeFromDateTime,
                ),
                SizedBox(height: layout == LayoutSize.mobile ? 8 : 10),
                if (_message != null) ...[
                  SizedBox(height: layout == LayoutSize.mobile ? 8 : 10),
                  _buildMessage(),
                ],
                SizedBox(height: layout == LayoutSize.mobile ? 8 : 12),
                Expanded(child: _buildBody(layout)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildProduttivitaPanel(LayoutSize layout) {
    final articolo = _articolo;
    if (articolo == null) return null;

    final media = _produttivitaArticolo?.mediaQuantitaMinuto;
    final corrente = _currentProduttivitaMinuto();
    final scostamento = media == null || media <= 0 || corrente == null ? null : ((corrente - media) / media) * 100;
    final anomala = scostamento != null && scostamento.abs() >= 20;
    final color = anomala ? const Color(0xFFB42318) : const Color(0xFF176B3A);
    final bg = anomala ? const Color(0xFFFFE4E2) : const Color(0xFFEAF7EE);
    final border = anomala ? const Color(0xFFF4A29A) : const Color(0xFFA6DDB8);

    String mediaText;
    if (_loadingProduttivita) {
      mediaText = 'Media in caricamento...';
    } else if (media == null || _produttivitaArticolo == null || _produttivitaArticolo!.numeroDichiarazioni == 0) {
      mediaText = 'Media non disponibile';
    } else {
      mediaText = 'Media ${_formatRate(media)} pz/min su ${_produttivitaArticolo!.numeroDichiarazioni} dichiarazioni';
    }

    final correnteText = corrente == null ? 'Resa corrente -' : 'Resa corrente ${_formatRate(corrente)} pz/min';
    final scostamentoText = scostamento == null ? '' : 'Scostamento ${scostamento >= 0 ? '+' : ''}${_formatPercent(scostamento)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(anomala ? Icons.warning_amber_outlined : Icons.speed_outlined, color: color, size: 20),
          Text(mediaText, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          Text(correnteText, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          if (scostamentoText.isNotEmpty) Text(scostamentoText, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  double? _currentProduttivitaMinuto() {
    final quantita = _parseDouble(_quantitaController.text);
    if (quantita <= 0) return null;
    if (_oraInizioProduzione == null || _oraFineProduzione == null) return null;
    final inizio = _combineDateTime(_oraInizioProduzione!);
    final fine = _combineDateTime(_oraFineProduzione!);
    final minuti = fine.difference(inizio).inSeconds / 60.0;
    if (minuti <= 0) return null;
    return quantita / minuti;
  }
  Widget _buildBody(LayoutSize layout) {
    if (_loadingDistinta && _componenti.isEmpty) {
      return const _LoadingState(message: 'Caricamento distinta e lotti componenti...');
    }

    if (_componenti.isEmpty) {
      return _EmptyState(
        message: _linee.isEmpty
            ? 'Nessuna linea configurata. Configurare almeno una linea di produzione.'
            : _linea == null
            ? 'Selezionare una linea di produzione.'
            : _articolo == null
            ? 'Selezionare un articolo associato alla linea e la quantita.'
            : 'Nessun componente trovato per la distinta selezionata.',
      );
    }

    return Stack(
      children: [
        if (layout == LayoutSize.mobile) _buildMobileCards() else _buildComponentTable(layout),
        if (_loadingDistinta)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 3),
          ),
      ],
    );
  }

  Widget _buildMobileCards() {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _componenti.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final componente = _componenti[index];
        return ComponentCard(
          componente: componente,
          selectedLot: _findLotto(componente),
          dateFormat: _dateFormat,
          onQuantitaChanged: (value) {
            setState(() => componente.quantitaDaScaricare = _parseDouble(value));
          },
          onLottoChanged: (value) {
            setState(() => componente.lotto = value);
          },
        );
      },
    );
  }

  Widget _buildComponentTable(LayoutSize layout) {
    final compact = layout == LayoutSize.tablet;
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        primary: false,
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            primary: false,
            child: DataTable(
              columnSpacing: compact ? 10 : 16,
              horizontalMargin: compact ? 10 : 16,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFE9EDF2)),
              dataRowMinHeight: compact ? 52 : 56,
              dataRowMaxHeight: compact ? 62 : 68,
              columns: const [
                DataColumn(label: Text('Codice')),
                DataColumn(label: Text('Descrizione')),
                DataColumn(label: Text('UM')),
                DataColumn(label: Text('Distinta')),
                DataColumn(label: Text('Proposta')),
                DataColumn(label: Text('Effettiva')),
                DataColumn(label: Text('Lotto')),
                DataColumn(label: Text('Disponibilita')),
                DataColumn(label: Text('Scadenza')),
              ],
              rows: _componenti.map((componente) => _buildRow(componente, compact)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(ComponenteDistinta componente, bool compact) {
    final selectedLot = _findLotto(componente);

    return DataRow(
      color: WidgetStateProperty.resolveWith((states) {
        if (componente.gestioneLotti && (componente.lotto == null || componente.lotto!.isEmpty)) {
          return const Color(0xFFFFF8E6);
        }
        return null;
      }),
      cells: [
        DataCell(SizedBox(width: compact ? 132 : 170, child: Text(componente.codComponente))),
        DataCell(
          SizedBox(
            width: compact ? 210 : 280,
            child: Text(componente.descrizione, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(componente.unitaMisura)),
        DataCell(Text(_formatNumber(componente.quantitaDistinta))),
        DataCell(Text(_formatNumber(componente.quantitaProposta))),
        DataCell(
          SizedBox(
            width: compact ? 96 : 120,
            child: _QuantitaEffettivaField(
              value: componente.quantitaDaScaricare,
              onChanged: (value) {
                setState(() => componente.quantitaDaScaricare = _parseDouble(value));
              },
            ),
          ),
        ),
        DataCell(
          LottoDropdown(
            componente: componente,
            selectedLot: selectedLot,
            dateFormat: _dateFormat,
            width: compact ? 248 : 300,
            onChanged: (value) {
              setState(() => componente.lotto = value);
            },
          ),
        ),
        DataCell(
          selectedLot == null
              ? const SizedBox.shrink()
              : DisponibilitaBadge(
                  disponibilita: selectedLot.disponibilita,
                  richiesta: componente.quantitaDaScaricare,
                ),
        ),
        DataCell(Text(selectedLot == null ? '' : _formatDate(selectedLot.dataScadenza))),
      ],
    );
  }

  Widget _buildMessage() {
    final colors = _messageColors(_messageKind);
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.fg.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(colors.icon, color: colors.fg, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message!,
              style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineaDropdown() {
    if (_loadingLinee) {
      return const TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Linea produzione',
          prefixIcon: Icon(Icons.precision_manufacturing_outlined),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _linea?.idLinea,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Linea produzione',
        prefixIcon: Icon(Icons.precision_manufacturing_outlined),
      ),
      items: _linee.map((linea) {
        return DropdownMenuItem<int>(
          value: linea.idLinea,
          child: Text(linea.label, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: _linee.isEmpty
          ? null
          : (value) {
              LineaProduzione? selected;
              for (final linea in _linee) {
                if (linea.idLinea == value) {
                  selected = linea;
                  break;
                }
              }
              setState(() {
                _linea = selected;
                _macchina = null;
                _articolo = null;
                _articoli = [];
                _componenti = [];
              });
              _loadArticoli();
            },
    );
  }
  Widget _buildMacchinaDropdown() {
    final disponibili = _macchine.where((m) => _linea == null || m.idLinea == null || m.idLinea == _linea!.idLinea).toList();

    if (_macchina != null && !disponibili.any((m) => m.idMacchina == _macchina!.idMacchina)) {
      _macchina = null;
    }

    return DropdownButtonFormField<int?>( 
      initialValue: _macchina?.idMacchina,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Macchina / risorsa',
        prefixIcon: Icon(Icons.memory_outlined),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Nessuna macchina')),
        ...disponibili.map((macchina) => DropdownMenuItem<int?>(value: macchina.idMacchina, child: Text(macchina.label, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: _saving ? null : (value) {
        setState(() {
          _macchina = disponibili.where((m) => m.idMacchina == value).cast<MacchinaProduzione?>().firstOrNull;
        });
      },
    );
  }

  Widget _buildArticoloAutocomplete() {
    if (_loadingArticoli) {
      return const TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Articolo producibile',
          prefixIcon: Icon(Icons.inventory_2_outlined),
        ),
      );
    }

    return Autocomplete<ArticoloProduzione>(
      displayStringForOption: (option) => option.label,
      optionsBuilder: (value) {
        final text = value.text.toLowerCase().trim();
        if (text.isEmpty) {
          return _articoli.take(30);
        }

        return _articoli.where((articolo) {
          return articolo.codArticolo.toLowerCase().contains(text) ||
              articolo.descrizione.toLowerCase().contains(text);
        }).take(30);
      },
      onSelected: (value) {
        setState(() => _articolo = value);
        _loadDistinta();
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: 1,
          maxLines: 1,
          decoration: const InputDecoration(
            labelText: 'Articolo producibile',
            prefixIcon: Icon(Icons.inventory_2_outlined),
          ),
          onSubmitted: (_) => _selezionaArticoloDaTesto(controller.text, controller),
        );
      },
    );
  }

  void _selezionaArticoloDaTesto(String value, TextEditingController controller) {
    final text = value.toLowerCase().trim();
    if (text.isEmpty) {
      return;
    }

    for (final articolo in _articoli) {
      if (articolo.codArticolo.toLowerCase() == text || articolo.label.toLowerCase() == text) {
        controller.text = articolo.label;
        setState(() => _articolo = articolo);
        _loadDistinta();
        return;
      }
    }
  }

  String _formatTime(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeNullable(TimeOfDay? value) {
    return value == null ? '-' : _formatTime(value);
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 3);
  }

  String _formatRate(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatPercent(double value) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatDate(DateTime? value) {
    return value == null ? '' : _dateFormat.format(value);
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  bool _isFutureDate(DateTime value) {
    final today = DateTime.now();
    final current = DateTime(today.year, today.month, today.day);
    final target = DateTime(value.year, value.month, value.day);
    return target.isAfter(current);
  }

  LottoProduzione? _findLotto(ComponenteDistinta componente) {
    for (final lotto in componente.lotti) {
      if (lotto.codiceLotto == componente.lotto) {
        return lotto;
      }
    }

    return null;
  }
}

class HeaderProduzione extends StatelessWidget {
  const HeaderProduzione({
    super.key,
    required this.layout,
    required this.lineaField,
    required this.macchinaField,
    required this.articoloField,
    required this.quantitaController,
    required this.magazzinoController,
    required this.lottoFinitoController,
    required this.dataLabel,
    required this.oraInizioLabel,
    required this.oraFineLabel,
    required this.saving,
    required this.canConfirm,
    required this.onDatePressed,
    required this.onOraInizioPressed,
    required this.onOraFinePressed,
    required this.onConfirmPressed,
    required this.onMagazzinoSubmitted,
    required this.confirmLabel,
    required this.savingLabel,
  });

  final LayoutSize layout;
  final Widget lineaField;
  final Widget macchinaField;
  final Widget articoloField;
  final TextEditingController quantitaController;
  final TextEditingController magazzinoController;
  final TextEditingController lottoFinitoController;
  final String dataLabel;
  final String oraInizioLabel;
  final String oraFineLabel;
  final bool saving;
  final bool canConfirm;
  final VoidCallback onDatePressed;
  final VoidCallback onOraInizioPressed;
  final VoidCallback onOraFinePressed;
  final VoidCallback onConfirmPressed;
  final VoidCallback onMagazzinoSubmitted;
  final String confirmLabel;
  final String savingLabel;

  @override
  Widget build(BuildContext context) {
    final padding = layout == LayoutSize.mobile ? 10.0 : 14.0;
    final spacing = layout == LayoutSize.mobile ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7DDE5)),
      ),
      child: layout == LayoutSize.mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _mobileFields(spacing),
            )
          : Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: _desktopFields(),
            ),
    );
  }

  List<Widget> _desktopFields() {
    final compact = layout == LayoutSize.tablet;
    return [
      SizedBox(width: compact ? 230 : 300, child: lineaField),
      SizedBox(width: compact ? 230 : 280, child: macchinaField),
      SizedBox(width: compact ? 320 : 430, child: articoloField),
      SizedBox(width: compact ? 120 : 150, child: _quantitaField()),
      SizedBox(width: compact ? 92 : 110, child: _magazzinoField()),
      SizedBox(width: compact ? 145 : 170, child: _lottoField()),
      SizedBox(width: compact ? 118 : 130, child: _dateButton()),
      SizedBox(width: compact ? 108 : 122, child: _timeButton('Inizio', oraInizioLabel, Icons.play_circle_outline, onOraInizioPressed)),
      SizedBox(width: compact ? 108 : 122, child: _timeButton('Fine', oraFineLabel, Icons.stop_circle_outlined, onOraFinePressed)),
      SizedBox(width: compact ? 184 : 218, child: _confirmButton()),
    ];
  }

  List<Widget> _mobileFields(double spacing) {
    return [
      lineaField,
      SizedBox(height: spacing),
      macchinaField,
      SizedBox(height: spacing),
      articoloField,
      SizedBox(height: spacing),
      Row(
        children: [
          Expanded(flex: 3, child: _quantitaField(compact: true)),
          SizedBox(width: spacing),
          Expanded(flex: 2, child: _magazzinoField(compact: true)),
          SizedBox(width: spacing),
          Expanded(flex: 3, child: _lottoField(compact: true)),
        ],
      ),
      SizedBox(height: spacing),
      Row(
        children: [
          Expanded(child: _dateButton(compact: true)),
          SizedBox(width: spacing),
          Expanded(child: _timeButton('Inizio', oraInizioLabel, Icons.play_circle_outline, onOraInizioPressed, compact: true)),
          SizedBox(width: spacing),
          Expanded(child: _timeButton('Fine', oraFineLabel, Icons.stop_circle_outlined, onOraFinePressed, compact: true)),
        ],
      ),
      SizedBox(height: spacing),
      _confirmButton(),
    ];
  }
  Widget _quantitaField({bool compact = false}) {
    return TextField(
      controller: quantitaController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: compact ? 16 : 18, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: compact ? 'Qta' : 'Quantita prodotta',
        prefixIcon: compact ? null : const Icon(Icons.scale_outlined),
        isDense: compact,
      ),
    );
  }

  Widget _magazzinoField({bool compact = false}) {
    return TextField(
      controller: magazzinoController,
      onSubmitted: (_) => onMagazzinoSubmitted(),
      decoration: InputDecoration(labelText: compact ? 'Mag.' : 'Magazzino PF', isDense: compact),
    );
  }

  Widget _lottoField({bool compact = false}) {
    return TextField(
      controller: lottoFinitoController,
      decoration: InputDecoration(labelText: compact ? 'Lotto' : 'Lotto prodotto', isDense: compact),
    );
  }

  Widget _dateButton({bool compact = false}) {
    return SizedBox(
      height: compact ? 44 : 48,
      child: OutlinedButton.icon(
        onPressed: onDatePressed,
        icon: Icon(Icons.calendar_today_outlined, size: compact ? 16 : 18),
        label: FittedBox(child: Text(dataLabel)),
      ),
    );
  }

  Widget _timeButton(String tooltip, String label, IconData icon, VoidCallback onPressed, {bool compact = false}) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: compact ? 44 : 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: compact ? 16 : 18),
          label: FittedBox(child: Text(label)),
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: saving || !canConfirm ? null : onConfirmPressed,
        icon: Icon(saving ? Icons.hourglass_top : Icons.check_circle_outline),
        label: FittedBox(child: Text(saving ? savingLabel : confirmLabel)),
      ),
    );
  }
}
class TeamOperativoSection extends StatelessWidget {
  const TeamOperativoSection({
    super.key,
    required this.operatori,
    required this.ruoli,
    required this.righe,
    required this.dataProduzione,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
    required this.teamDateTime,
    required this.timeFromDateTime,
  });

  final List<OperatoreProduzione> operatori;
  final List<RuoloOperativo> ruoli;
  final List<DichiarazioneOperatore> righe;
  final DateTime dataProduzione;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;
  final DateTime? Function(TimeOfDay? value) teamDateTime;
  final TimeOfDay? Function(DateTime? value) timeFromDateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7DDE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Color(0xFF2D465C)),
              const SizedBox(width: 8),
              Expanded(child: Text('Team operativo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              OutlinedButton.icon(onPressed: enabled ? onAdd : null, icon: const Icon(Icons.add), label: const Text('Operatore')),
            ],
          ),
          if (righe.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('Nessun operatore indicato per questa dichiarazione.', style: TextStyle(color: Color(0xFF667085))),
          ] else ...[
            const SizedBox(height: 10),
            ...List.generate(righe.length, (index) => _TeamOperativoRow(
                  row: righe[index],
                  operatori: operatori,
                  ruoli: ruoli,
                  enabled: enabled,
                  onRemove: () => onRemove(index),
                  onChanged: onChanged,
                  teamDateTime: teamDateTime,
                  timeFromDateTime: timeFromDateTime,
                )),
          ],
        ],
      ),
    );
  }
}

class _TeamOperativoRow extends StatelessWidget {
  const _TeamOperativoRow({
    required this.row,
    required this.operatori,
    required this.ruoli,
    required this.enabled,
    required this.onRemove,
    required this.onChanged,
    required this.teamDateTime,
    required this.timeFromDateTime,
  });

  final DichiarazioneOperatore row;
  final List<OperatoreProduzione> operatori;
  final List<RuoloOperativo> ruoli;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final DateTime? Function(TimeOfDay? value) teamDateTime;
  final TimeOfDay? Function(DateTime? value) timeFromDateTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 270,
            child: DropdownButtonFormField<int>(
              initialValue: row.idOperatore,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Operatore', isDense: true),
              items: operatori.map((op) => DropdownMenuItem<int>(value: op.idOperatore, child: Text(op.label, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: !enabled ? null : (value) {
                final selected = operatori.where((op) => op.idOperatore == value).cast<OperatoreProduzione?>().firstOrNull;
                row.idOperatore = value;
                row.codOperatoreSnapshot = selected?.codOperatore;
                row.nomeOperatoreSnapshot = selected == null ? null : [selected.nome, selected.cognome].where((e) => e != null && e.trim().isNotEmpty).join(' ');
                row.costoOrarioApplicato = selected?.costoOrarioRiferimento;
                onChanged();
              },
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<int>(
              initialValue: row.idRuoloOperativo,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Ruolo', isDense: true),
              items: ruoli.map((ruolo) => DropdownMenuItem<int>(value: ruolo.idRuoloOperativo, child: Text(ruolo.label, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: !enabled ? null : (value) {
                final selected = ruoli.where((r) => r.idRuoloOperativo == value).cast<RuoloOperativo?>().firstOrNull;
                row.idRuoloOperativo = value;
                row.ruoloSnapshot = selected?.descrizione;
                onChanged();
              },
            ),
          ),
          _TeamTimeButton(label: 'Inizio', value: timeFromDateTime(row.oraInizio), enabled: enabled, onChanged: (value) { row.oraInizio = teamDateTime(value); onChanged(); }),
          _TeamTimeButton(label: 'Fine', value: timeFromDateTime(row.oraFine), enabled: enabled, onChanged: (value) { row.oraFine = teamDateTime(value); onChanged(); }),
          SizedBox(
            width: 130,
            child: TextFormField(
              initialValue: row.costoOrarioApplicato?.toString() ?? '',
              enabled: enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo/h', isDense: true),
              onChanged: (value) {
                row.costoOrarioApplicato = double.tryParse(value.replaceAll(',', '.'));
                onChanged();
              },
            ),
          ),
          SizedBox(
            width: 260,
            child: TextFormField(
              initialValue: row.note,
              enabled: enabled,
              decoration: const InputDecoration(labelText: 'Note', isDense: true),
              onChanged: (value) => row.note = value,
            ),
          ),
          IconButton.outlined(onPressed: enabled ? onRemove : null, icon: const Icon(Icons.delete_outline), tooltip: 'Rimuovi operatore'),
        ],
      ),
    );
  }
}

class _TeamTimeButton extends StatelessWidget {
  const _TeamTimeButton({required this.label, required this.value, required this.enabled, required this.onChanged});

  final String label;
  final TimeOfDay? value;
  final bool enabled;
  final ValueChanged<TimeOfDay?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '-' : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
    return SizedBox(
      width: 116,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: !enabled ? null : () async {
          final picked = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
          if (picked != null) onChanged(picked);
        },
        icon: const Icon(Icons.schedule_outlined, size: 16),
        label: FittedBox(child: Text('$label $text')),
      ),
    );
  }
}
class ComponentCard extends StatelessWidget {
  const ComponentCard({
    super.key,
    required this.componente,
    required this.selectedLot,
    required this.dateFormat,
    required this.onQuantitaChanged,
    required this.onLottoChanged,
  });

  final ComponenteDistinta componente;
  final LottoProduzione? selectedLot;
  final DateFormat dateFormat;
  final ValueChanged<String> onQuantitaChanged;
  final ValueChanged<String?> onLottoChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD7DDE5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    componente.codComponente,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2D3A)),
                  ),
                ),
                if (componente.gestioneLotti) const LottoBadge(),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              componente.descrizione,
              style: const TextStyle(fontSize: 14, color: Color(0xFF394B59), height: 1.25),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'UM', value: componente.unitaMisura),
                _InfoChip(label: 'Distinta', value: _formatNumber(componente.quantitaDistinta)),
                _InfoChip(label: 'Proposta', value: _formatNumber(componente.quantitaProposta)),
              ],
            ),
            const SizedBox(height: 12),
            _QuantitaEffettivaField(
              value: componente.quantitaDaScaricare,
              onChanged: onQuantitaChanged,
              labelText: 'Quantita effettiva',
            ),
            if (componente.gestioneLotti) ...[
              const SizedBox(height: 12),
              LottoDropdown(
                componente: componente,
                selectedLot: selectedLot,
                dateFormat: dateFormat,
                onChanged: onLottoChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DisponibilitaBadge(
                      disponibilita: selectedLot?.disponibilita ?? 0,
                      richiesta: componente.quantitaDaScaricare,
                      expanded: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      label: 'Scadenza',
                      value: selectedLot == null ? '-' : _formatDate(selectedLot!.dataScadenza, dateFormat),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LottoDropdown extends StatelessWidget {
  const LottoDropdown({
    super.key,
    required this.componente,
    required this.selectedLot,
    required this.dateFormat,
    required this.onChanged,
    this.width,
  });

  final ComponenteDistinta componente;
  final LottoProduzione? selectedLot;
  final DateFormat dateFormat;
  final ValueChanged<String?> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (!componente.gestioneLotti) {
      return SizedBox(width: width ?? 0);
    }

    final content = componente.lotti.isEmpty
        ? Row(
            children: const [
              LottoBadge(),
              SizedBox(width: 8),
              Expanded(child: Text('Nessun lotto disponibile', style: TextStyle(color: Color(0xFF9E1B24)))),
            ],
          )
        : Row(
            children: [
              const LottoBadge(),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: componente.lotto,
                  isExpanded: true,
                  itemHeight: 58,
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  selectedItemBuilder: (context) {
                    return componente.lotti.map((lotto) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${lotto.codiceLotto} - disp. ${_formatNumber(lotto.disponibilita)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList();
                  },
                  items: componente.lotti.map((lotto) {
                    return DropdownMenuItem(
                      value: lotto.codiceLotto,
                      child: _LottoOption(lotto: lotto, dateFormat: dateFormat),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          );

    return SizedBox(width: width, child: content);
  }
}

class DisponibilitaBadge extends StatelessWidget {
  const DisponibilitaBadge({
    super.key,
    required this.disponibilita,
    required this.richiesta,
    this.expanded = false,
  });

  final double disponibilita;
  final double richiesta;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = _availabilityColors(disponibilita, richiesta);
    return Container(
      constraints: BoxConstraints(minHeight: 38, minWidth: expanded ? double.infinity : 82),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: colors.fg.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: expanded ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expanded)
            Text('Disponibilita', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.fg)),
          Text(
            _formatNumber(disponibilita),
            textAlign: expanded ? TextAlign.left : TextAlign.right,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class LottoBadge extends StatelessWidget {
  const LottoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF9BBAD6)),
      ),
      child: const Text(
        'LOTTO',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF174A7C)),
      ),
    );
  }
}

class _QuantitaEffettivaField extends StatefulWidget {
  const _QuantitaEffettivaField({
    required this.value,
    required this.onChanged,
    this.labelText,
  });

  final double value;
  final ValueChanged<String> onChanged;
  final String? labelText;

  @override
  State<_QuantitaEffettivaField> createState() => _QuantitaEffettivaFieldState();
}

class _QuantitaEffettivaFieldState extends State<_QuantitaEffettivaField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatNumber(widget.value));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _QuantitaEffettivaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      final nextText = _formatNumber(widget.value);
      if (_controller.text != nextText) {
        _controller.value = TextEditingValue(
          text: nextText,
          selection: TextSelection.collapsed(offset: nextText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      style: const TextStyle(fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.labelText,
        constraints: const BoxConstraints(minHeight: 48),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF667684), fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1F2D3A), fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _LottoOption extends StatelessWidget {
  const _LottoOption({required this.lotto, required this.dateFormat});

  final LottoProduzione lotto;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lotto.codiceLotto, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(
          'Disponibilita ${_formatNumber(lotto.disponibilita)}${lotto.dataScadenza == null ? '' : ' - Scadenza ${_formatDate(lotto.dataScadenza, dateFormat)}'}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xFF667684)),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD7DDE5)),
        ),
        child: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

LayoutSize layoutFor(double width) {
  if (width >= 1000) {
    return LayoutSize.desktop;
  }
  if (width >= 700) {
    return LayoutSize.tablet;
  }
  return LayoutSize.mobile;
}

({Color bg, Color fg}) _availabilityColors(double disponibilita, double richiesta) {
  if (disponibilita >= richiesta && disponibilita > 0) {
    return (bg: const Color(0xFFE8F5EE), fg: const Color(0xFF176B3A));
  }

  if (disponibilita > 0) {
    return (bg: const Color(0xFFFFF4E0), fg: const Color(0xFF9A5B00));
  }

  return (bg: const Color(0xFFFCEBEC), fg: const Color(0xFF9E1B24));
}

({Color bg, Color fg, IconData icon}) _messageColors(_MessageKind kind) {
  return switch (kind) {
    _MessageKind.info => (bg: const Color(0xFFEAF2FB), fg: const Color(0xFF174A7C), icon: Icons.info_outline),
    _MessageKind.success => (bg: const Color(0xFFE8F5EE), fg: const Color(0xFF176B3A), icon: Icons.check_circle_outline),
    _MessageKind.error => (bg: const Color(0xFFFCEBEC), fg: const Color(0xFF9E1B24), icon: Icons.error_outline),
  };
}

String _formatNumber(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 3);
}

String _formatDate(DateTime? value, DateFormat dateFormat) {
  return value == null ? '-' : dateFormat.format(value);
}





































































