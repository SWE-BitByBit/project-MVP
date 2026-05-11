import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/settings/widget/settings_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/dead_man_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/widget/dead_man_form_widget.dart';

// --- MOCKS ---
class MockDeadManViewModel extends Mock implements DeadManViewModel {}
class MockCommandLoad extends Mock implements Command<void, void> {}
class MockCommandSave extends Mock implements Command<void, void> {}

void main() {
  late MockDeadManViewModel mockVm;
  late MockCommandLoad mockLoadCommand;
  late MockCommandSave mockSaveCommand;

  setUp(() async {
    // 1. Pulizia e inizializzazione sicura di GetIt (Asincrona)
    final sl = GetIt.instance;
    await sl.reset();

    mockVm = MockDeadManViewModel();
    mockLoadCommand = MockCommandLoad();
    mockSaveCommand = MockCommandSave();

    // 2. Setup minimo per far sopravvivere il DeadManFormWidget annidato
    // Non ci serve simulare i dati veri, ci basta che non crashi per Notifier nulli.
    when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockLoadCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));
    when(() => mockSaveCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockSaveCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));

    when(() => mockVm.loadSettings).thenReturn(mockLoadCommand);
    when(() => mockVm.saveSettings).thenReturn(mockSaveCommand);

    // Restituendo null per la bozza, DeadManFormWidget renderizzerà un semplice SizedBox.shrink()
    // permettendoci di testare tranquillamente il resto della schermata.
    when(() => mockVm.draftSettings).thenReturn(null);

    // Registriamo il Mock nel Service Locator, dato che SettingsScreen usa getIt<DeadManViewModel>()
    sl.registerSingleton<DeadManViewModel>(mockVm);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SettingsScreen(),
    );
  }

  group('SettingsScreen - Layout & Interazioni', () {
    testWidgets('renderizza la AppBar con il titolo corretto', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Impostazioni'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renderizza i 3 pannelli (ExpansionTile)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica la presenza dei 3 titoli dei tab
      expect(find.text('Allarme Automatico'), findsOneWidget);
      expect(find.text('Privacy e Dati'), findsOneWidget);
      expect(find.text('Informazioni App'), findsOneWidget);

      // Essendo originallyExpanded: true, il Form è già nell'albero
      expect(find.byType(DeadManFormWidget), findsOneWidget);
    });

    testWidgets('espande la tab "Privacy e Dati" al tocco e mostra i contenuti', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final privacyTabFinder = find.text('Privacy e Dati');
      expect(privacyTabFinder, findsOneWidget);

      // Tocca la tab per espanderla
      await tester.tap(privacyTabFinder);
      await tester.pumpAndSettle(); // Aspetta l'animazione di espansione

      // Verifica che il testo interno sia ora visibile
      expect(find.text('Gestione dei consensi e della privacy in arrivo...'), findsOneWidget);
    });

    testWidgets('espande la tab "Informazioni App" al tocco e mostra la versione', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final infoTabFinder = find.text('Informazioni App');

      // Essendo l'ultimo elemento in una lista, potrebbe non essere visibile su schermi piccoli.
      // Eseguiamo uno scroll per assicurarci che sia visibile e cliccabile.
      await tester.dragUntilVisible(
        infoTabFinder,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Tocca la tab per espanderla
      await tester.tap(infoTabFinder);
      await tester.pumpAndSettle();

      // Verifica che il testo interno sia ora visibile
      expect(find.text('Versione MVP 1.0.0'), findsOneWidget);
    });
  });
}
