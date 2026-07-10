import 'package:flutter/material.dart';

import '../modelli/produzione.dart';
import '../servizi/produzione_service.dart';

class LineeProduzionePage extends StatefulWidget {
  const LineeProduzionePage({super.key});

  @override
  State<LineeProduzionePage> createState() => _LineeProduzionePageState();
}

class _LineeProduzionePageState extends State<LineeProduzionePage> {
  final _service = ProduzioneService();
  final _codController = TextEditingController();
  final _nomeController = TextEditingController();
  final _descrizioneController = TextEditingController();

  List<LineaProduzione> _linee = [];
  List<ArticoloProduzione> _articoli = [];
  List<ArticoloProduzione> _articoliLinea = [];
  LineaProduzione? _selectedLinea;
  ArticoloProduzione? _selectedArticolo;
  bool _editingNew = false;
  bool _lineaAttiva = true;
  bool _loading = true;
  bool _loadingDetail = false;
  bool _saving = false;
  bool _addingArticle = false;
  bool _showAddArticle = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codController.dispose();
    _nomeController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  Future<void> _load({String? selectCodLinea}) async {
    setState(() => _loading = true);
    try {
      final linee = await _service.getLinee(soloAttive: false);
      final articoli = await _service.getArticoli();
      if (!mounted) return;

      LineaProduzione? nextSelected;
      if (selectCodLinea != null) {
        for (final linea in linee) {
          if (linea.codLinea == selectCodLinea) {
            nextSelected = linea;
            break;
          }
        }
      } else if (_selectedLinea != null) {
        for (final linea in linee) {
          if (linea.idLinea == _selectedLinea!.idLinea) {
            nextSelected = linea;
            break;
          }
        }
      }

      setState(() {
        _linee = linee;
        _articoli = articoli;
        _selectedLinea = nextSelected;
        _loading = false;
      });

      if (nextSelected != null) {
        _fillMaster(nextSelected);
        await _loadArticoliLinea(nextSelected);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Errore caricamento linee: $e', isError: true);
    }
  }

  void _fillMaster(LineaProduzione linea) {
    _editingNew = false;
    _codController.text = linea.codLinea;
    _nomeController.text = linea.nomeLinea;
    _descrizioneController.text = linea.descrizioneFunzionale ?? '';
    _lineaAttiva = linea.attiva;
  }

  Future<void> _selectLinea(LineaProduzione linea) async {
    setState(() {
      _selectedLinea = linea;
      _fillMaster(linea);
      _articoliLinea = [];
      _selectedArticolo = null;
      _showAddArticle = false;
    });
    await _loadArticoliLinea(linea);
  }

  Future<void> _loadArticoliLinea(LineaProduzione linea) async {
    setState(() => _loadingDetail = true);
    try {
      final articoli = await _service.getArticoliLinea(linea.idLinea);
      if (!mounted) return;
      setState(() {
        _articoliLinea = articoli;
        _loadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDetail = false);
      _showMessage('Errore caricamento articoli linea: $e', isError: true);
    }
  }

  void _newLinea() {
    setState(() {
      _selectedLinea = null;
      _editingNew = true;
      _lineaAttiva = true;
      _codController.clear();
      _nomeController.clear();
      _descrizioneController.clear();
      _articoliLinea = [];
      _selectedArticolo = null;
      _showAddArticle = false;
    });
  }

  void _backToList() {
    setState(() {
      _selectedLinea = null;
      _editingNew = false;
      _articoliLinea = [];
      _selectedArticolo = null;
      _showAddArticle = false;
    });
  }

  Future<void> _saveLinea() async {
    final codLinea = _codController.text.trim();
    final nomeLinea = _nomeController.text.trim();
    if (codLinea.isEmpty || nomeLinea.isEmpty) {
      _showMessage('Codice e nome linea sono obbligatori.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.salvaLinea(
        idLinea: _selectedLinea?.idLinea,
        codLinea: codLinea,
        nomeLinea: nomeLinea,
        descrizioneFunzionale: _descrizioneController.text,
        attiva: _lineaAttiva,
      );
      await _load(selectCodLinea: codLinea);
      if (!mounted) return;
      setState(() => _editingNew = false);
      _showMessage('Linea salvata.');
    } catch (e) {
      _showMessage('Errore salvataggio linea: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _associaArticolo() async {
    final linea = _selectedLinea;
    final articolo = _selectedArticolo;
    if (linea == null || articolo == null) {
      _showMessage('Selezionare un articolo da assegnare.', isError: true);
      return;
    }

    setState(() => _addingArticle = true);
    try {
      await _service.associaArticoloLinea(linea.idLinea, articolo.codArticolo);
      await _loadArticoliLinea(linea);
      if (!mounted) return;
      setState(() {
        _selectedArticolo = null;
        _showAddArticle = false;
      });
      _showMessage('Articolo assegnato alla linea.');
    } catch (e) {
      _showMessage('Errore associazione articolo: $e', isError: true);
    } finally {
      if (mounted) setState(() => _addingArticle = false);
    }
  }

  Future<void> _rimuoviArticolo(ArticoloProduzione articolo) async {
    final linea = _selectedLinea;
    if (linea == null) return;

    setState(() => _addingArticle = true);
    try {
      await _service.rimuoviArticoloLinea(linea.idLinea, articolo.codArticolo);
      await _loadArticoliLinea(linea);
      _showMessage('Articolo rimosso dalla linea.');
    } catch (e) {
      _showMessage('Errore rimozione articolo: $e', isError: true);
    } finally {
      if (mounted) setState(() => _addingArticle = false);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? const Color(0xFFB42318) : const Color(0xFF16803C),
      ),
    );
  }

  bool get _hasDetail => _selectedLinea != null || _editingNew;

  List<ArticoloProduzione> get _articoliDisponibili {
    final assigned = _articoliLinea.map((e) => e.codArticolo).toSet();
    return _articoli.where((articolo) => !assigned.contains(articolo.codArticolo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linee di produzione')),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = MediaQuery.sizeOf(context).width < 700;
          if (!mobile || _hasDetail) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: _newLinea,
            tooltip: 'Nuova linea',
            child: const Icon(Icons.add),
          );
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final mobile = width < 700;
                final desktop = width >= 1000;

                if (!_hasDetail) {
                  return _buildListOnly(mobile: mobile, desktop: desktop);
                }

                if (mobile) {
                  return _buildDetail(mobile: true);
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: desktop ? 380 : 300,
                        child: _LineeList(
                          linee: _linee,
                          selected: _selectedLinea,
                          compact: !desktop,
                          onSelected: _selectLinea,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDetail(mobile: false)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildListOnly({required bool mobile, required bool desktop}) {
    return Padding(
      padding: EdgeInsets.all(mobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Linee configurate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (!mobile)
                FilledButton.icon(
                  onPressed: _newLinea,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuova linea'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _LineeList(
              linee: _linee,
              selected: _selectedLinea,
              compact: !desktop,
              onSelected: _selectLinea,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail({required bool mobile}) {
    return ListView(
      padding: EdgeInsets.all(mobile ? 12 : 0),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: _backToList,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Torna alle linee',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _editingNew ? 'Nuova linea' : _selectedLinea!.codLinea,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!mobile)
              TextButton.icon(
                onPressed: _newLinea,
                icon: const Icon(Icons.add),
                label: const Text('Nuova'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMaster(mobile: mobile),
        const SizedBox(height: 16),
        if (!_editingNew) _buildArticoliDetail(mobile: mobile),
        if (_editingNew)
          const _EmptyPanel(
            icon: Icons.info_outline,
            text: 'Salvare la linea prima di assegnare articoli.',
          ),
      ],
    );
  }

  Widget _buildMaster({required bool mobile}) {
    final fields = [
      TextField(
        controller: _codController,
        enabled: !_saving,
        decoration: const InputDecoration(labelText: 'Codice linea'),
      ),
      TextField(
        controller: _nomeController,
        enabled: !_saving,
        decoration: const InputDecoration(labelText: 'Descrizione linea'),
      ),
      SwitchListTile(
        value: _lineaAttiva,
        onChanged: _saving ? null : (value) => setState(() => _lineaAttiva = value),
        title: const Text('Linea attiva'),
        subtitle: Text(_lineaAttiva ? 'Disponibile in dichiarazione produzione' : 'Dismessa, mantenuta per storico'),
        contentPadding: EdgeInsets.zero,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dati linea', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (mobile)
            ...fields.expand((field) => [field, const SizedBox(height: 12)])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: fields[0]),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: fields[1]),
                const SizedBox(width: 12),
                SizedBox(width: 260, child: fields[2]),
              ],
            ),
          TextField(
            controller: _descrizioneController,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Note operative'),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveLinea,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('Salva linea'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticoliDetail({required bool mobile}) {
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
                  'Articoli assegnati',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _addingArticle ? null : () => setState(() => _showAddArticle = !_showAddArticle),
                icon: const Icon(Icons.add),
                tooltip: 'Aggiungi articolo',
              ),
            ],
          ),
          if (_showAddArticle) ...[
            const SizedBox(height: 12),
            _buildAddArticleRow(mobile: mobile),
          ],
          const SizedBox(height: 12),
          if (_loadingDetail)
            const LinearProgressIndicator(minHeight: 3)
          else if (_articoliLinea.isEmpty)
            const _EmptyPanel(icon: Icons.inventory_2_outlined, text: 'Nessun articolo assegnato a questa linea.')
          else if (mobile)
            ..._articoliLinea.map((articolo) => _ArticleCard(articolo: articolo, onDelete: () => _rimuoviArticolo(articolo)))
          else
            _ArticleTable(articoli: _articoliLinea, onDelete: _rimuoviArticolo),
        ],
      ),
    );
  }

  Widget _buildAddArticleRow({required bool mobile}) {
    final dropdown = DropdownButtonFormField<ArticoloProduzione>(
      initialValue: _selectedArticolo,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Articolo producibile'),
      items: _articoliDisponibili.map((articolo) {
        return DropdownMenuItem(
          value: articolo,
          child: Text(articolo.label, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: _addingArticle ? null : (value) => setState(() => _selectedArticolo = value),
    );

    final button = FilledButton.icon(
      onPressed: _addingArticle || _articoliDisponibili.isEmpty ? null : _associaArticolo,
      icon: _addingArticle
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.add_link),
      label: const Text('Assegna'),
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [dropdown, const SizedBox(height: 10), button],
      );
    }

    return Row(
      children: [
        Expanded(child: dropdown),
        const SizedBox(width: 12),
        button,
      ],
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD7DDE5)),
    );
  }
}

class _LineeList extends StatelessWidget {
  const _LineeList({
    required this.linee,
    required this.selected,
    required this.compact,
    required this.onSelected,
  });

  final List<LineaProduzione> linee;
  final LineaProduzione? selected;
  final bool compact;
  final ValueChanged<LineaProduzione> onSelected;

  @override
  Widget build(BuildContext context) {
    if (linee.isEmpty) {
      return const _EmptyPanel(icon: Icons.precision_manufacturing_outlined, text: 'Nessuna linea configurata.');
    }

    return ListView.separated(
      itemCount: linee.length,
      separatorBuilder: (context, index) => SizedBox(height: compact ? 8 : 10),
      itemBuilder: (context, index) {
        final linea = linee[index];
        final active = selected?.idLinea == linea.idLinea;
        return InkWell(
          onTap: () => onSelected(linea),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 10 : 12),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFEAF2FB) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: active ? const Color(0xFF2F6EA3) : const Color(0xFFD7DDE5)),
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LineCodeRow(linea: linea),
                      const SizedBox(height: 4),
                      Text(linea.nomeLinea, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 2, child: _LineCodeRow(linea: linea)),
                      const SizedBox(width: 12),
                      Expanded(flex: 4, child: Text(linea.nomeLinea, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _LineCodeRow extends StatelessWidget {
  const _LineCodeRow({required this.linea});

  final LineaProduzione linea;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            linea.codLinea,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        if (!linea.attiva) ...[
          const SizedBox(width: 8),
          const _StatusBadge(text: 'Dismessa', color: Color(0xFF8A5A00), background: Color(0xFFFFF4D6)),
        ],
      ],
    );
  }
}

class _ArticleTable extends StatelessWidget {
  const _ArticleTable({required this.articoli, required this.onDelete});

  final List<ArticoloProduzione> articoli;
  final ValueChanged<ArticoloProduzione> onDelete;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.6),
        1: FlexColumnWidth(3.4),
        2: FixedColumnWidth(60),
        3: FixedColumnWidth(56),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE9EEF4)),
          children: [
            _TableHeader('Codice'),
            _TableHeader('Descrizione'),
            _TableHeader('UM'),
            SizedBox(height: 44),
          ],
        ),
        ...articoli.map(
          (articolo) => TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE1E5EA)))),
            children: [
              _TableCell(articolo.codArticolo, bold: true),
              _TableCell(articolo.descrizione),
              _TableCell(articolo.unitaMisura),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => onDelete(articolo),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Rimuovi associazione',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.articolo, required this.onDelete});

  final ArticoloProduzione articolo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7DDE5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(articolo.codArticolo, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(articolo.descrizione),
                if (articolo.unitaMisura.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('UM ${articolo.unitaMisura}', style: const TextStyle(color: Color(0xFF667085))),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Rimuovi associazione',
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w400),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color, required this.background});

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7DDE5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667085)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475467)))),
        ],
      ),
    );
  }
}
