import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/sos/widget/sos_pull_top_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/sos/view_model/sos_view_model.dart';

// --- MOCKS ---
class MockSosViewModel extends Mock implements SosViewModel {}
class MockCommandSendAlert extends Mock implements Command<void, void> {}

void main() {
  late MockSosViewModel mockVm;
  late MockCommandSendAlert mockSendAlertCommand;
  late ValueNotifier<bool> isRunningNotifier;

  setUp(() {
    mockVm = MockSosViewModel();
    mockSendAlertCommand = MockCommandSendAlert();
    isRunningNotifier = ValueNotifier<bool>(false);

    // Setup base del Command
    when(() => mockSendAlertCommand.isRunning).thenReturn(isRunningNotifier);
    when(() => mockSendAlertCommand.runAsync()).thenAnswer((_) async {});

    // Associa il command al VM
    when(() => mockVm.sendAlert).thenReturn(mockSendAlertCommand);

    when(() => mockVm.checkConnection()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      // Scaffold è necessario per far funzionare la SnackBar
      home: Scaffold(
        body: ChangeNotifierProvider<SosViewModel>.value(
          value: mockVm,
          // Mettiamo il widget in un align right come farebbe verosimilmente la UI reale,
          // per dare spazio di drag in basso.
          child: const Align(
            alignment: Alignment.topRight,
            child: SosPullTopWidget(),
          ),
        ),
      ),
    );
  }

  group('SosPullTopWidget - Rendering', () {
    testWidgets('mostra il Container rosso e l\'icona freccia in stato di riposo', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Cerca il Container decorato
      expect(find.byType(Container), findsOneWidget);
      // Cerca l'icona
      expect(find.byIcon(Icons.keyboard_double_arrow_down), findsOneWidget);
      // Non deve esserci la scritta SOS finché non si tira giù
      expect(find.text('SOS'), findsNothing);
      // Nessun caricamento visibile
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('mostra il CircularProgressIndicator se l\'alert è in corso', (tester) async {
      // Impostiamo il notifier su true per simulare l'attesa asincrona
      isRunningNotifier.value = true;

      await tester.pumpWidget(createWidgetUnderTest());

      // L'icona deve sparire, deve esserci lo spinner
      expect(find.byIcon(Icons.keyboard_double_arrow_down), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SosPullTopWidget - Dragging Interactions', () {
    testWidgets('un drag INFERIORE a 550px non innesca l\'alert', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final target = find.byType(Container);

      // Usiamo drag(finder, Offset) per simulare lo swipe verticale
      // Trasciniamo verso il basso di soli 300 pixel (sotto la soglia di 550)
      await tester.drag(target, const Offset(0, 300));
      await tester.pumpAndSettle(); // Aspettiamo eventuali riposizionamenti

      // Il comando NON deve essere chiamato
      verifyNever(() => mockSendAlertCommand.runAsync());
    });

    testWidgets('un drag SUPERIORE a 550px innesca l\'alert e mostra SnackBar di Successo', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final target = find.byType(Container);

      // Trasciniamo verso il basso di 600 pixel (oltre la soglia di 550)
      await tester.drag(target, const Offset(0, 600));
      await tester.pumpAndSettle();

      // Il comando DEVE essere stato chiamato esattamente 1 volta
      verify(() => mockSendAlertCommand.runAsync()).called(1);

      // Siccome il nostro mock ritorna regolarmente senza errori, cerchiamo il feedback di successo
      expect(find.text('🚨 SOS INVIATO!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('mostra SnackBar di ERRORE se runAsync lancia un\'eccezione', (tester) async {
      // Simuliamo che la chiamata fallisca per un problema di rete/server
      when(() => mockSendAlertCommand.runAsync()).thenThrow(Exception('No Network'));

      await tester.pumpWidget(createWidgetUnderTest());

      final target = find.byType(Container);

      // Eseguiamo un drag valido
      await tester.drag(target, const Offset(0, 600));
      await tester.pumpAndSettle();

      // Il comando è stato chiamato
      verify(() => mockSendAlertCommand.runAsync()).called(1);

      // Il try/catch interno al widget intercetta l'eccezione e mostra lo SnackBar rosso
      expect(find.text(' INVIO FALLITO. Controlla la connessione.'), findsOneWidget);
    });
  });
}