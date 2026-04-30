import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_form_widget.dart';

// --- MOCKS ---
class MockTrustedContactViewModel extends Mock implements TrustedContactViewModel {}
class MockCommandDelete extends Mock implements Command<String, void> {}
class MockCommandUpdate extends Mock implements Command<TrustedContact, void> {}
class MockCommandCreate extends Mock implements Command<TrustedContact, void> {}

// --- FALLBACKS ---
class FakeTrustedContact extends Fake implements TrustedContact {}

void main() {
  late MockTrustedContactViewModel mockVm;
  late MockCommandDelete mockDeleteCommand;
  late MockCommandUpdate mockUpdateCommand;
  late MockCommandCreate mockCreateCommand;

  setUpAll(() {
    registerFallbackValue(FakeTrustedContact());
  });

  setUp(() {
    mockVm = MockTrustedContactViewModel();
    mockDeleteCommand = MockCommandDelete();
    mockUpdateCommand = MockCommandUpdate();
    mockCreateCommand = MockCommandCreate();

    // Setup base ViewModel
    when(() => mockVm.contacts).thenReturn([]);

    // Setup Delete Command
    when(() => mockDeleteCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockDeleteCommand.errors).thenReturn(ValueNotifier<CommandError<String>?>(null));
    when(() => mockDeleteCommand.runAsync(any())).thenAnswer((_) async {});
    when(() => mockVm.deleteContact).thenReturn(mockDeleteCommand);

    // Setup Update Command (Fondamentale per far sopravvivere il form in modalità modifica)
    when(() => mockUpdateCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockUpdateCommand.errors).thenReturn(ValueNotifier<CommandError<TrustedContact>?>(null));
    when(() => mockVm.updateContact).thenReturn(mockUpdateCommand);

    // Setup Create Command (Fondamentale per far sopravvivere il form)
    when(() => mockCreateCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockCreateCommand.errors).thenReturn(ValueNotifier<CommandError<TrustedContact>?>(null));
    when(() => mockVm.createContact).thenReturn(mockCreateCommand);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TrustedContactViewModel>.value(
          value: mockVm,
          child: const TrustedContactListWidget(),
        ),
      ),
    );
  }

  group('TrustedContactListWidget - Stati di Rendering', () {
    testWidgets('mostra il messaggio "Nessun contatto" quando la lista è vuota', (tester) async {
      when(() => mockVm.contacts).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nessun contatto fidato'), findsOneWidget);
      expect(find.byIcon(Icons.group_off), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('mostra una ListView con i dettagli se ci sono contatti salvati', (tester) async {
      when(() => mockVm.contacts).thenReturn([
        TrustedContact(
          id: '1',
          name: 'Giulia Bianchi',
          email: 'giulia@email.com',
          phoneNumber: '3331112233',
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Giulia Bianchi'), findsOneWidget);
      // expect per il sotttotitolo multilinea
      expect(find.text('giulia@email.com\n3331112233'), findsOneWidget);
      // expect per l'iniziale nell'avatar
      expect(find.text('G'), findsOneWidget);
    });
  });

  group('TrustedContactListWidget - Interazioni Utente', () {
    testWidgets('tap su un ListTile apre il form di modifica', (tester) async {
      when(() => mockVm.contacts).thenReturn([
        TrustedContact(
          id: '1',
          name: 'Marco Neri',
          email: 'marco@email.com',
          phoneNumber: '3330001122',
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      // Assicuriamoci che non ci sia il form a schermo
      expect(find.byType(TrustedContactFormWidget), findsNothing);

      // Tap sul contatto (la card)
      await tester.tap(find.text('Marco Neri'));
      await tester.pumpAndSettle(); // Animazione del BottomSheet

      // Verifica che la modale con il form sia comparsa
      expect(find.byType(TrustedContactFormWidget), findsOneWidget);
    });

    testWidgets('tap sul cestino mostra un Dialog e conferma elimina invoca runAsync', (tester) async {
      when(() => mockVm.contacts).thenReturn([
        TrustedContact(
          id: '123-abc',
          name: 'Marco Neri',
          email: 'marco@email.com',
          phoneNumber: '3330001122',
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Troviamo e premiamo l'icona del cestino
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle(); // Apre il Dialog

      // 2. Verifichiamo che il Dialog sia apparso con i dati corretti
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Elimina Contatto'), findsOneWidget);
      expect(find.text('Rimuovere Marco Neri dai contatti fidati?'), findsOneWidget);

      // 3. Premiamo il tasto di conferma eliminazione
      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle(); // Chiude il Dialog

      // 4. Verifichiamo che il Dialog non ci sia più
      expect(find.byType(AlertDialog), findsNothing);

      // 5. Controlliamo che il viewModel sia stato istruito per eliminare l'ID corretto
      verify(() => mockDeleteCommand.runAsync('123-abc')).called(1);
    });
  });
}