import 'package:flutter/material.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class MacchinePage extends StatefulWidget {
  const MacchinePage({super.key});

  @override
  State<MacchinePage> createState() => _MacchinePageState();
}

class _MacchinePageState extends State<MacchinePage> {
  final _service = ProduzioneService();
  final _controllers = <String, TextEditingController>{};
  List<MacchinaProduzione> _macchine = [];
  List<LineaProduzione> _linee = [];
  int? _selectedId;
  int? _idLinea;
  bool _loading = true;
  bool _saving = false;

  static const _identity = [
    _Spec('codMacchina', 'Codice macchina', required: true),
    _Spec('nomeMacchina', 'Nome', required: true),
    _Spec('descrizione', 'Descrizione'),
    _Spec('reparto', 'Reparto'),
    _Spec('costruttore', 'Costruttore'),
    _Spec('modello', 'Modello'),
    _Spec('matricola', 'Matricola'),
    _Spec('annoInstallazione', 'Anno installazione', number: true),
    _Spec('stato', 'Stato'),
  ];
  static const _production = [
    _Spec('unitaMisuraPrincipale', 'UM principale'),
    _Spec('velocitaNominale', 'Velocita nominale', number: true),
    _Spec('velocitaOttimale', 'Velocita ottimale', number: true),
    _Spec('velocitaMassima', 'Velocita massima', number: true),
    _Spec('capacitaMassimaTurno', 'Capacita max turno', number: true),
    _Spec('capacitaMassimaGiornaliera', 'Capacita max giorno', number: true),
    _Spec('capacitaMassimaSettimanale', 'Capacita max settimana', number: true),
    _Spec('tempoMinimoLottoMinuti', 'Tempo minimo lotto min', number: true),
    _Spec('tempoMassimoLottoMinuti', 'Tempo massimo lotto min', number: true),
  ];
  static const _costs = [
    _Spec('costoAmmortamentoOra', 'Ammortamento euro/h', number: true),
    _Spec('costoManutenzioneOra', 'Manutenzione euro/h', number: true),
    _Spec('costoEnergiaVuotoOra', 'Energia a vuoto euro/h', number: true),
    _Spec('costoEnergiaProduzioneOra', 'Energia produzione euro/h', number: true),
    _Spec('costoLubrificantiOra', 'Lubrificanti euro/h', number: true),
    _Spec('costoUtensiliOra', 'Utensili euro/h', number: true),
    _Spec('costoPuliziaOra', 'Pulizia euro/h', number: true),
    _Spec('costoFermoMacchinaOra', 'Fermo macchina euro/h', number: true),
    _Spec('costoOccupazioneSpazioOra', 'Spazio euro/h', number: true),
  ];
  static const _times = [
    _Spec('tempoRiscaldamentoMinuti', 'Riscaldamento min', number: true),
    _Spec('tempoRaffreddamentoMinuti', 'Raffreddamento min', number: true),
    _Spec('tempoCambioFormatoStandardMinuti', 'Cambio formato min', number: true),
    _Spec('tempoPuliziaStandardMinuti', 'Pulizia standard min', number: true),
    _Spec('tempoSanificazioneMinuti', 'Sanificazione min', number: true),
    _Spec('tempoSetupBaseMinuti', 'Setup base min', number: true),
    _Spec('tempoAvviamentoMinuti', 'Avviamento min', number: true),
    _Spec('tempoArrestoMinuti', 'Arresto min', number: true),
    _Spec('consumoKwSpunto', 'Consumo kW spunto', number: true),
    _Spec('consumoKwFunzione', 'Consumo kW funzione', number: true),
    _Spec('unitaMinutoBenchmark', 'Benchmark unita/min', number: true),
    _Spec('noteTecniche', 'Note tecniche'),
  ];

  @override
  void initState() {
    super.initState();
    for (final spec in [..._identity, ..._production, ..._costs, ..._times]) {
      _controllers[spec.key] = TextEditingController();
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([_service.getMacchine(), _service.getLinee(soloAttive: false)]);
      if (!mounted) return;
      setState(() {
        _macchine = results[0] as List<MacchinaProduzione>;
        _linee = results[1] as List<LineaProduzione>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Errore caricamento macchine: $e', error: true);
    }
  }

  void _new() {
    setState(() {
      _selectedId = null;
      _idLinea = null;
      for (final c in _controllers.values) {
        c.clear();
      }
      _controllers['stato']!.text = 'ATTIVA';
    });
  }

  void _select(MacchinaProduzione m) {
    setState(() {
      _selectedId = m.idMacchina;
      _idLinea = m.idLinea;
      void set(String key, Object? value) => _controllers[key]!.text = value?.toString() ?? '';
      set('codMacchina', m.codMacchina); set('nomeMacchina', m.nomeMacchina); set('descrizione', m.descrizione); set('reparto', m.reparto); set('costruttore', m.costruttore); set('modello', m.modello); set('matricola', m.matricola); set('annoInstallazione', m.annoInstallazione); set('stato', m.stato);
      set('unitaMisuraPrincipale', m.unitaMisuraPrincipale); set('velocitaNominale', m.velocitaNominale); set('velocitaOttimale', m.velocitaOttimale); set('velocitaMassima', m.velocitaMassima); set('capacitaMassimaTurno', m.capacitaMassimaTurno); set('capacitaMassimaGiornaliera', m.capacitaMassimaGiornaliera); set('capacitaMassimaSettimanale', m.capacitaMassimaSettimanale); set('tempoMinimoLottoMinuti', m.tempoMinimoLottoMinuti); set('tempoMassimoLottoMinuti', m.tempoMassimoLottoMinuti);
      set('costoAmmortamentoOra', m.costoAmmortamentoOra); set('costoManutenzioneOra', m.costoManutenzioneOra); set('costoEnergiaVuotoOra', m.costoEnergiaVuotoOra); set('costoEnergiaProduzioneOra', m.costoEnergiaProduzioneOra); set('costoLubrificantiOra', m.costoLubrificantiOra); set('costoUtensiliOra', m.costoUtensiliOra); set('costoPuliziaOra', m.costoPuliziaOra); set('costoFermoMacchinaOra', m.costoFermoMacchinaOra); set('costoOccupazioneSpazioOra', m.costoOccupazioneSpazioOra);
      set('tempoRiscaldamentoMinuti', m.tempoRiscaldamentoMinuti); set('tempoRaffreddamentoMinuti', m.tempoRaffreddamentoMinuti); set('tempoCambioFormatoStandardMinuti', m.tempoCambioFormatoStandardMinuti); set('tempoPuliziaStandardMinuti', m.tempoPuliziaStandardMinuti); set('tempoSanificazioneMinuti', m.tempoSanificazioneMinuti); set('tempoSetupBaseMinuti', m.tempoSetupBaseMinuti); set('tempoAvviamentoMinuti', m.tempoAvviamentoMinuti); set('tempoArrestoMinuti', m.tempoArrestoMinuti); set('consumoKwSpunto', m.consumoKwSpunto); set('consumoKwFunzione', m.consumoKwFunzione); set('unitaMinutoBenchmark', m.unitaMinutoBenchmark); set('noteTecniche', m.noteTecniche);
    });
  }

  Future<void> _save({bool attiva = true}) async {
    if (_controllers['codMacchina']!.text.trim().isEmpty || _controllers['nomeMacchina']!.text.trim().isEmpty) {
      _message('Codice e nome macchina sono obbligatori.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.salvaMacchina(
        idMacchina: _selectedId,
        idLinea: _idLinea,
        codMacchina: _txt('codMacchina')!, nomeMacchina: _txt('nomeMacchina')!, descrizione: _txt('descrizione'), reparto: _txt('reparto'), costruttore: _txt('costruttore'), modello: _txt('modello'), matricola: _txt('matricola'), annoInstallazione: _int('annoInstallazione'), stato: _txt('stato'), unitaMisuraPrincipale: _txt('unitaMisuraPrincipale'),
        velocitaNominale: _num('velocitaNominale'), velocitaOttimale: _num('velocitaOttimale'), velocitaMassima: _num('velocitaMassima'), capacitaMassimaTurno: _num('capacitaMassimaTurno'), capacitaMassimaGiornaliera: _num('capacitaMassimaGiornaliera'), capacitaMassimaSettimanale: _num('capacitaMassimaSettimanale'), tempoMinimoLottoMinuti: _num('tempoMinimoLottoMinuti'), tempoMassimoLottoMinuti: _num('tempoMassimoLottoMinuti'),
        costoAmmortamentoOra: _num('costoAmmortamentoOra'), costoManutenzioneOra: _num('costoManutenzioneOra'), costoEnergiaVuotoOra: _num('costoEnergiaVuotoOra'), costoEnergiaProduzioneOra: _num('costoEnergiaProduzioneOra'), costoLubrificantiOra: _num('costoLubrificantiOra'), costoUtensiliOra: _num('costoUtensiliOra'), costoPuliziaOra: _num('costoPuliziaOra'), costoFermoMacchinaOra: _num('costoFermoMacchinaOra'), costoOccupazioneSpazioOra: _num('costoOccupazioneSpazioOra'),
        tempoRiscaldamentoMinuti: _num('tempoRiscaldamentoMinuti'), tempoRaffreddamentoMinuti: _num('tempoRaffreddamentoMinuti'), tempoCambioFormatoStandardMinuti: _num('tempoCambioFormatoStandardMinuti'), tempoPuliziaStandardMinuti: _num('tempoPuliziaStandardMinuti'), tempoSanificazioneMinuti: _num('tempoSanificazioneMinuti'), tempoSetupBaseMinuti: _num('tempoSetupBaseMinuti'), tempoAvviamentoMinuti: _num('tempoAvviamentoMinuti'), tempoArrestoMinuti: _num('tempoArrestoMinuti'), consumoKwSpunto: _num('consumoKwSpunto'), consumoKwFunzione: _num('consumoKwFunzione'), unitaMinutoBenchmark: _num('unitaMinutoBenchmark'), noteTecniche: _txt('noteTecniche'), attiva: attiva,
      );
      _new();
      await _load();
      _message(attiva ? 'Macchina salvata.' : 'Macchina resa non attiva per usi futuri.');
    } catch (e) {
      _message('Errore salvataggio macchina: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _txt(String key) { final v = _controllers[key]!.text.trim(); return v.isEmpty ? null : v; }
  double? _num(String key) => double.tryParse(_controllers[key]!.text.trim().replaceAll(',', '.'));
  int? _int(String key) => int.tryParse(_controllers[key]!.text.trim());

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 1000;
      final master = _master();
      final detail = _detail(wide);
      return wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 390, child: master), const VerticalDivider(width: 1), Expanded(child: detail)])
          : ListView(padding: const EdgeInsets.all(12), children: [master, const SizedBox(height: 12), detail]);
    });
  }

  Widget _master() => ListView(
    padding: const EdgeInsets.all(12),
    shrinkWrap: true,
    children: [
      Row(children: [Expanded(child: Text('Macchine', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), IconButton(onPressed: _new, icon: const Icon(Icons.add), tooltip: 'Nuova macchina')]),
      const SizedBox(height: 8),
      ..._macchine.map((m) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: _selectedId == m.idMacchina ? const Color(0xFFE1EEF9) : null,
        child: ListTile(
          onTap: () => _select(m),
          title: Text(m.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${m.codLinea ?? 'Linea -'} • ${m.reparto ?? 'Reparto -'} • ${m.stato ?? '-'}'),
          trailing: m.attiva ? const Icon(Icons.check_circle_outline, color: Colors.green) : const Icon(Icons.block_outlined, color: Colors.red),
        ),
      )),
    ],
  );

  Widget _detail(bool wide) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(_selectedId == null ? 'Nuova macchina' : 'Dettaglio macchina', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      DropdownButtonFormField<int?>(initialValue: _idLinea, decoration: const InputDecoration(labelText: 'Linea di appartenenza'), items: [const DropdownMenuItem<int?>(value: null, child: Text('Nessuna linea')), ..._linee.map((l) => DropdownMenuItem<int?>(value: l.idLinea, child: Text(l.label, overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => _idLinea = v)),
      _section('Identita', _identity, wide),
      _section('Caratteristiche produttive', _production, wide),
      _section('Costi propri', _costs, wide),
      _section('Parametri operativi', _times, wide),
      Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(onPressed: _saving ? null : () => _save(), icon: const Icon(Icons.save_outlined), label: const Text('Salva macchina')),
        if (_selectedId != null) OutlinedButton.icon(onPressed: _saving ? null : () => _save(attiva: false), icon: const Icon(Icons.block_outlined), label: const Text('Rendi non attiva')),
      ]),
    ],
  );

  Widget _section(String title, List<_Spec> specs, bool wide) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: specs
            .map(
              (s) => SizedBox(
                width: wide ? 250 : double.infinity,
                child: TextField(
                  controller: _controllers[s.key],
                  keyboardType: s.number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  decoration: InputDecoration(labelText: s.required ? '${s.label} *' : s.label),
                ),
              ),
            )
            .toList(),
      ),
    ]),
  );

  void _message(String text, {bool error = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700));
}

class _Spec {
  final String key;
  final String label;
  final bool number;
  final bool required;
  const _Spec(this.key, this.label, {this.number = false, this.required = false});
}


