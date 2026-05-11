import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

// --- MOCKS ---
class MockTrustedContactViewModel extends Mock
    implements TrustedContactViewModel {}

class MockCommandCreate extends Mock implements Command<TrustedContact, void> {}

class MockCommandUpdate extends Mock implements Command<TrustedContact, void> {}

class MockCommandError extends Mock implements CommandError<TrustedContact> {}

// Fallback fittizio per intercettare parametri
class FakeTrustedContact extends Fake implements TrustedContact {}

void main() {
  late MockTrustedContactViewModel mockVm;
  late MockCommandCreate mockCreateCommand;
  late MockCommandUpdate mockUpdateCommand;
  late ValueNotifier<bool> createRunningNotifier;
  late ValueNotifier<CommandError<TrustedContact>?> createErrorNotifier;
  late ValueNotifier<bool> updateRunningNotifier;
  late ValueNotifier<CommandError<TrustedContact>?> updateErrorNotifier;

  late bool onDismissCalled;

  setUpAll(() {
    registerFallbackValue(FakeTrustedContact());
  });

  setUp(() {
    mockVm = MockTrustedContactViewModel();
    mockCreateCommand = MockCommandCreate();
    mockUpdateCommand = MockCommandUpdate();

    createRunningNotifier = ValueNotifier<bool>(false);
    createErrorNotifier = ValueNotifier<CommandError<TrustedContact>?>(null);
    updateRunningNotifier = ValueNotifier<bool>(false);
    updateErrorNotifier = ValueNotifier<CommandError<TrustedContact>?>(null);

    // Setup Create Command
    when(() => mockCreateCommand.isRunning).thenReturn(createRunningNotifier);
    when(() => mockCreateCommand.errors).thenReturn(createErrorNotifier);
    when(() => mockCreateCommand.runAsync(any())).thenAnswer((_) async {});

    // Setup Update Command
    when(() => mockUpdateCommand.isRunning).thenReturn(updateRunningNotifier);
    when(() => mockUpdateCommand.errors).thenReturn(updateErrorNotifier);
    when(() => mockUpdateCommand.runAsync(any())).thenAnswer((_) async {});

    // Setup VM
    when(() => mockVm.createContact).thenReturn(mockCreateCommand);
    when(() => mockVm.updateContact).thenReturn(mockUpdateCommand);
    when(() => mockVm.errors).thenReturn(<String, String>{});

    onDismissCalled = false;
  });

  Widget createWidgetUnderTest({TrustedContact? initialContact}) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TrustedContactViewModel>.value(
          value: mockVm,
          child: TrustedContactFormWidget(
            initialContact: initialContact,
            onDismiss: () {
              onDismissCalled = true;
            },
          ),
        ),
      ),
    );
  }

  group('TrustedContactFormWidget - Validazione & Rendering', () {
    testWidgets(
      'mostra messaggi di errore se si tenta di salvare con campi vuoti',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Il bottone in modalità creazione
        await tester.tap(find.text('Salva contatto'));
        await tester.pumpAndSettle();

        expect(find.text('Inserisci il nome'), findsOneWidget);
        expect(find.text('Inserisci il numero di telefono'), findsOneWidget);
        expect(find.text('Inserisci l\'email'), findsOneWidget);

        // Assicuriamoci che il comando non sia stato chiamato
        verifyNever(() => mockCreateCommand.runAsync(any()));
        expect(onDismissCalled, isFalse);
      },
    );

    testWidgets(
      'pre-popola i campi se viene passato un initialContact e adatta i testi',
      (tester) async {
        final existingContact = TrustedContact(
          id: '123',
          name: 'Mario Rossi',
          email: 'mario@email.com',
          phoneNumber: '3331234567',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(initialContact: existingContact),
        );

        // Verifica titolo e bottone adatti alla modalità Modifica
        expect(find.text('Modifica Contatto'), findsOneWidget);
        expect(find.text('Aggiorna contatto'), findsOneWidget);

        // Verifica campi testo pre-popolati
        expect(find.text('Mario Rossi'), findsOneWidget);
        expect(find.text('3331234567'), findsOneWidget);
        expect(find.text('mario@email.com'), findsOneWidget);
      },
    );
  });

  group('TrustedContactFormWidget - Creazione Contatto', () {
    testWidgets(
      'chiama createContact con i dati inseriti e invoca onDismiss su successo',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Compiliamo il form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome e Cognome'),
          'Luigi Bianchi',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Numero di Cellulare'),
          '3339876543',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Indirizzo Email'),
          'luigi@email.com',
        );

        await tester.tap(find.text('Salva contatto'));
        await tester.pumpAndSettle();

        // Verifica l'oggetto catturato
        final captured = verify(
          () => mockCreateCommand.runAsync(captureAny()),
        ).captured;
        final contactPassed = captured.first as TrustedContact;

        expect(contactPassed.name, 'Luigi Bianchi');
        expect(contactPassed.phoneNumber, '3339876543');
        expect(contactPassed.email, 'luigi@email.com');
        // ID vuoto perché in creazione
        expect(contactPassed.id, '');

        // Nessun errore simulato, quindi il form deve essersi chiuso
        expect(onDismissCalled, isTrue);
      },
    );

    testWidgets('NON invoca onDismiss se createContact emette errori', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome e Cognome'),
        'Test Error',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Numero di Cellulare'),
        '123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Indirizzo Email'),
        'a@b.c',
      );

      // Mettiamo un errore di fallback che comparirà durante il runAsyc
      // (Il widget legge errorNotifier.value subito dopo l'await runAsync)
      when(() => mockCreateCommand.runAsync(any())).thenAnswer((_) async {
        createErrorNotifier.value = MockCommandError();
      });

      await tester.tap(find.text('Salva contatto'));
      await tester.pumpAndSettle();

      expect(onDismissCalled, isFalse);
    });
  });

  group('TrustedContactFormWidget - Modifica Contatto', () {
    testWidgets('chiama updateContact mantenendo l\'ID originale', (
      tester,
    ) async {
      final existingContact = TrustedContact(
        id: 'ABC-123',
        name: 'Vecchio Nome',
        email: 'vecchia@email.com',
        phoneNumber: '0000',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(initialContact: existingContact),
      );

      // Modifichiamo solo un campo
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome e Cognome'),
        'Nuovo Nome',
      );

      await tester.tap(find.text('Aggiorna contatto'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockUpdateCommand.runAsync(captureAny()),
      ).captured;
      final contactPassed = captured.first as TrustedContact;

      expect(contactPassed.id, 'ABC-123'); // ID DEVE RIMANERE INVARIATO
      expect(contactPassed.name, 'Nuovo Nome'); // Nome aggiornato

      expect(onDismissCalled, isTrue);
    });
  });

  group('TrustedContactFormWidget - Stato Caricamento', () {
    testWidgets(
      'mostra il CircularProgressIndicator sul bottone durante l\'esecuzione (modalità Creazione)',
      (tester) async {
        createRunningNotifier.value = true;

        await tester.pumpWidget(createWidgetUnderTest());
        await tester
            .pump(); // Usiamo pump e non pumpAndSettle per via dell'animazione di caricamento

        // Il bottone è diventato un CircularProgressIndicator
        expect(find.text('Salva contatto'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
