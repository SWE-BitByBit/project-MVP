import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/settings/widget/dead_man_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/dead_man_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';

// --- MOCKS ---
class MockDeadManViewModel extends Mock implements DeadManViewModel {}
class MockCommandLoad extends Mock implements Command<void, void> {}
class MockCommandSave extends Mock implements Command<void, void> {}
class MockCommandError extends Mock implements CommandError<void> {}

void main() {
  late MockDeadManViewModel mockVm;
  late MockCommandLoad mockLoadCommand;
  late MockCommandSave mockSaveCommand;

  // Notifiers per simulare la reattività dei Command di command_it
  late ValueNotifier<bool> loadIsRunningNotifier;
  late ValueNotifier<CommandError<void>?> loadErrorsNotifier;
  late ValueNotifier<bool> saveIsRunningNotifier;
  late ValueNotifier<CommandError<void>?> saveErrorsNotifier;

  /// Helper per creare una bozza standard di test
  DeadManSettings createDummySettings() {
    return DeadManSettings(
      isActive: true,
      firstInactivityTimer: 3,
      secondInactivityTimer: 1,
      messageSubject: 'Emergenza',
      messageBody: 'Aiuto, controllate se sto bene.',
    );
  }

  setUp(() {
    mockVm = MockDeadManViewModel();
    mockLoadCommand = MockCommandLoad();
    mockSaveCommand = MockCommandSave();

    loadIsRunningNotifier = ValueNotifier<bool>(false);
    loadErrorsNotifier = ValueNotifier<CommandError<void>?>(null);
    saveIsRunningNotifier = ValueNotifier<bool>(false);
    saveErrorsNotifier = ValueNotifier<CommandError<void>?>(null);

    // Setup Load Command
    when(() => mockLoadCommand.isRunning).thenReturn(loadIsRunningNotifier);
    when(() => mockLoadCommand.errors).thenReturn(loadErrorsNotifier);
    when(() => mockLoadCommand.run()).thenReturn(null);

    // Setup Save Command
    when(() => mockSaveCommand.isRunning).thenReturn(saveIsRunningNotifier);
    when(() => mockSaveCommand.errors).thenReturn(saveErrorsNotifier);
    when(() => mockSaveCommand.runAsync()).thenAnswer((_) async {});

    // Setup ViewModel
    when(() => mockVm.loadSettings).thenReturn(mockLoadCommand);
    when(() => mockVm.saveSettings).thenReturn(mockSaveCommand);
    when(() => mockVm.draftSettings).thenReturn(createDummySettings());
    when(() => mockVm.hasUnsavedChanges).thenReturn(false);
  });

  // Funzione helper per montare il widget isolato
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<DeadManViewModel>.value(
          value: mockVm,
          child: const DeadManFormWidget(),
        ),
      ),
    );
  }

  group('DeadManFormWidget - Rendering Stati Iniziali', () {
    testWidgets('Mostra CircularProgressIndicator quando in caricamento e senza draft', (tester) async {
      when(() => mockVm.draftSettings).thenReturn(null);
      loadIsRunningNotifier.value = true;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('Mostra ErrorIndicator se il caricamento fallisce a draft vuota', (tester) async {
      when(() => mockVm.draftSettings).thenReturn(null);
      loadErrorsNotifier.value = MockCommandError();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorIndicator), findsOneWidget);
      expect(find.text('Impossibile caricare'), findsOneWidget);

      // Tap sul retry
      await tester.tap(find.text('Riprova'));
      verify(() => mockLoadCommand.run()).called(1);
    });
  });

  group('DeadManFormWidget - Rendering Form (Dati caricati)', () {
    testWidgets('Popola correttamente tutti i campi dalla draftSettings', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica interruttore
      expect(find.text('Stato Allarme'), findsOneWidget);
      expect(find.text('Attivo e in monitoraggio'), findsOneWidget);

      // Verifica testi sliders (valori di testo)
      expect(find.text('3 gg'), findsOneWidget);
      expect(find.text('1 gg'), findsOneWidget);

      // Verifica i TextField se contengono i valori
      expect(find.text('Emergenza'), findsOneWidget);
      expect(find.text('Aiuto, controllate se sto bene.'), findsOneWidget);
    });

    testWidgets('Il bottone Salva è disabilitato se hasUnsavedChanges è falso', (tester) async {
      when(() => mockVm.hasUnsavedChanges).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull); // isNull = disabilitato
    });

    testWidgets('Mostra CircularProgressIndicator nel bottone durante il salvataggio', (tester) async {
      when(() => mockVm.hasUnsavedChanges).thenReturn(true);
      saveIsRunningNotifier.value = true; // Simuliamo caricamento in corso

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Usiamo pump invece di pumpAndSettle per via dell'animazione infinita

      // Dentro il Row del bottone Salva
      final circularProgressFinder = find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(CircularProgressIndicator),
      );

      expect(circularProgressFinder, findsOneWidget);
    });
  });

  group('DeadManFormWidget - Interazioni Utente', () {
    testWidgets('Tap sullo Switch chiama toggleActiveStatus nel VM', (tester) async {
      // Usiamo una variabile falsa per il fallback di mocktail
      when(() => mockVm.toggleActiveStatus(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Poiché lo stato iniziale è true, il tap invia false
      verify(() => mockVm.toggleActiveStatus(false)).called(1);
    });

    testWidgets('Digitare nei TextField chiama updateMessage nel VM', (tester) async {
      when(() => mockVm.updateMessage(any(), any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Scriviamo nel campo Oggetto
      await tester.enterText(find.widgetWithText(TextFormField, 'Emergenza'), 'Nuovo Oggetto');

      // Il widget richiama updateMessage con il nuovo testo e il vecchio body
      verify(() => mockVm.updateMessage('Nuovo Oggetto', 'Aiuto, controllate se sto bene.')).called(1);
    });

    testWidgets('Tap su Salva chiama runAsync e mostra SnackBar di successo', (tester) async {
      when(() => mockVm.hasUnsavedChanges).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap bottone Salva
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle(); // Aspetta la fine del comando asincrono

      verify(() => mockSaveCommand.runAsync()).called(1);

      // Verifica comparsa SnackBar di successo
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Impostazioni salvate!'), findsOneWidget);
    });

  });
}