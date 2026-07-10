import 'package:flutter/material.dart';

import 'agenda_produzione_page.dart';
import 'dichiarazione_produzione_page.dart';
import 'impostazioni_page.dart';
import 'linee_produzione_page.dart';
import 'macchine_page.dart';
import 'processi_produttivi_page.dart';
import 'storico_dichiarazioni_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _menuExpanded = true;
  DateTime _dataNuovaDichiarazione = DateTime.now();

  static const _items = <_MenuItem>[
    _MenuItem('Calendario dichiarazioni', Icons.calendar_month_outlined),
    _MenuItem('Agenda Produzione', Icons.event_note_outlined),
    _MenuItem('Dichiarazione', Icons.assignment_turned_in_outlined),
    _MenuItem('Impostazioni', Icons.tune_outlined),
    _MenuItem('Operatori e ruoli', Icons.badge_outlined),
    _MenuItem('Team operativi', Icons.groups_2_outlined),
    _MenuItem('Macchine', Icons.precision_manufacturing_outlined),
    _MenuItem('Setup', Icons.construction_outlined),
    _MenuItem('Costi produzione', Icons.euro_symbol_outlined),
    _MenuItem('Assegnazione articoli', Icons.account_tree_outlined),
    _MenuItem('Processi produttivi', Icons.route_outlined),
  ];

  Widget _buildPage() {
    return switch (_selectedIndex) {
      0 => StoricoDichiarazioniPage(
          onNuovaDichiarazione: (data) => setState(() {
            _dataNuovaDichiarazione = data;
            _selectedIndex = 2;
          }),
        ),
      1 => const AgendaProduzionePage(),
      2 => DichiarazioneProduzionePage(
          key: ValueKey(_dataNuovaDichiarazione.toIso8601String()),
          initialDate: _dataNuovaDichiarazione,
        ),
      3 => const ImpostazioniPage(key: ValueKey('config'), initialTab: 0),
      4 => const ImpostazioniPage(key: ValueKey('operatori'), initialTab: 1),
      5 => const ImpostazioniPage(key: ValueKey('team'), initialTab: 2),
      6 => const MacchinePage(),
      7 => const ImpostazioniPage(key: ValueKey('setup'), initialTab: 4),
      8 => const ImpostazioniPage(key: ValueKey('costi'), initialTab: 5),
      9 => const LineeProduzionePage(),
      _ => const ProcessiProduttiviPage(),
    };
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            leading: desktop
                ? IconButton(
                    tooltip: _menuExpanded ? 'Riduci menu' : 'Espandi menu',
                    icon: Icon(_menuExpanded ? Icons.menu_open : Icons.menu),
                    onPressed: () => setState(() => _menuExpanded = !_menuExpanded),
                  )
                : Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            title: Text(_items[_selectedIndex].label),
          ),
          drawer: desktop ? null : Drawer(child: SafeArea(child: _MenuList(selectedIndex: _selectedIndex, onSelected: _selectFromDrawer))),
          body: desktop
              ? Row(
                  children: [
                    _SideMenu(
                      expanded: _menuExpanded,
                      selectedIndex: _selectedIndex,
                      onSelected: (index) => setState(() => _selectedIndex = index),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildPage()),
                  ],
                )
              : _buildPage(),
        );
      },
    );
  }

  void _selectFromDrawer(int index) {
    Navigator.of(context).pop();
    setState(() => _selectedIndex = index);
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({required this.expanded, required this.selectedIndex, required this.onSelected});

  final bool expanded;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: expanded ? 250 : 72,
      color: const Color(0xFF24384A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 58,
              child: Center(
                child: expanded
                    ? const Text('FactoryFlow', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))
                    : const Icon(Icons.factory_outlined, color: Colors.white),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF3A5063)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _AppShellState._items.length,
                itemBuilder: (context, index) {
                  final item = _AppShellState._items[index];
                  final selected = selectedIndex == index;
                  return Tooltip(
                    message: expanded ? '' : item.label,
                    child: InkWell(
                      onTap: () => onSelected(index),
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF365F86) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 22),
                            if (expanded) ...[
                              const SizedBox(width: 12),
                              Expanded(child: Text(item.label, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontWeight: selected ? FontWeight.w800 : FontWeight.w600))),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const ListTile(title: Text('FactoryFlow', style: TextStyle(fontWeight: FontWeight.w800))),
        const Divider(),
        ..._AppShellState._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ListTile(
            selected: selectedIndex == index,
            leading: Icon(item.icon),
            title: Text(item.label),
            onTap: () => onSelected(index),
          );
        }),
      ],
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;

  const _MenuItem(this.label, this.icon);
}





