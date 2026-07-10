import 'package:factoryflow_flutter/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('collaudo dichiarazione produzione reale da Flutter Web', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await _pumpUntil(tester, find.widgetWithText(TextField, 'Articolo producibile'));

    await tester.enterText(
      find.widgetWithText(TextField, 'Articolo producibile'),
      'CAPSULABIALETTIDIST',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    await _pumpUntil(tester, find.text('CAPSULABIALETTI'), timeout: const Duration(seconds: 30));
    await _pumpUntil(tester, find.textContaining('0090'), timeout: const Duration(seconds: 30));
    expect(find.text('CAPSULABIALETTI'), findsOneWidget);
    expect(find.text('CARTAALLUMINIOMICROF'), findsOneWidget);
    expect(find.text('CARTAFILTRO1'), findsOneWidget);
    expect(find.text('TOPBIALETTI'), findsOneWidget);
    expect(find.textContaining('0090'), findsWidgets);
    expect(find.textContaining('JOB 20295'), findsWidgets);
    expect(find.textContaining('22-1335-002'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextField, 'Lotto prodotto'),
      'FFWEB',
    );
    await tester.pump();

    await tester.tap(find.text('CONFERMA PRODUZIONE'));
    await tester.pump();

    await _pumpUntil(
      tester,
      find.textContaining('Dichiarazione produzione confermata'),
      timeout: const Duration(seconds: 45),
    );

    expect(find.textContaining('Dichiarazione produzione confermata'), findsOneWidget);
  });
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('Finder non trovato entro timeout.');
}
