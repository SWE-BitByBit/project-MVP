import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contacts_screen.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  group('TrustedContactListWidget Widget Test', () {
    late MockTrustedContactRepository mockRepo;
    late TrustedContactViewModel viewModel;

    setUp(() {
      mockRepo = MockTrustedContactRepository();
      viewModel = TrustedContactViewModel(mockRepo);
    });

    /// Helper: monta TrustedContactListWidget con il Provider.
    Future<void> pumpListWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TrustedContactViewModel>.value(
              value: viewModel,
              child: const TrustedContactListWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'Stato vuoto: deve mostrare il messaggio "Nessun contatto fidato"',
      (WidgetTester tester) async {
        // Nessun contatto caricato -> lista vuota
        await pumpListWidget(tester);

        expect(find.text('Nessun contatto fidato'), findsOneWidget);
        expect(find.byIcon(Icons.group_off), findsOneWidget);
      },
    );

    testWidgets('mostra CircularProgressIndicator durante il loading', (
      tester,
    ) async {
      final mockRepo = MockTrustedContactRepository()
        ..simulatedDelay = const Duration(seconds: 1);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TrustedContactViewModel(mockRepo),
          child: const MaterialApp(home: TrustedContactScreenView()),
        ),
      );

      // Primo frame: il Future NON è ancora completato
      await tester.pump();

      // Loader visibile
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Facciamo finire il delay
      await tester.pumpAndSettle();

      // Loader sparisce
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Popolato: deve mostrare tutti i contatti caricati', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockRepo.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Mario Rossi',
          email: 'mario@email.com',
          phoneNumber: '+39 333 0000001',
        ),
        TrustedContact(
          id: 'c-2',
          name: 'Laura Bianchi',
          email: 'laura@email.com',
          phoneNumber: '+39 333 0000002',
        ),
      ];
      await viewModel.loadContacts.execute();
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      // Assert: i nomi sono visibili nella lista
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('Laura Bianchi'), findsOneWidget);
    });

    testWidgets('Il click sul pulsante elimina mostra il dialog di conferma', (
      WidgetTester tester,
    ) async {
      // Arrange: un contatto in lista
      mockRepo.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Da Eliminare',
          email: 'x@x.com',
          phoneNumber: '0001',
        ),
      ];
      await viewModel.loadContacts.execute();
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      // Act: tocchiamo l'icona del cestino
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Assert: il dialog di conferma è apparso
      expect(find.text('Elimina Contatto'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(find.text('Elimina'), findsOneWidget);
    });

    testWidgets('Il click su "Annulla" nel dialog chiude senza eliminare', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockRepo.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Stabile',
          email: 'a@a.com',
          phoneNumber: '0001',
        ),
      ];
      await viewModel.loadContacts.execute();
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      // Apriamo il dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Annulla'), findsOneWidget);

      // Annulliamo
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      // Il dialog è chiuso e il contatto c'è ancora
      expect(find.text('Elimina Contatto'), findsNothing);
      expect(viewModel.contacts.length, 1);
    });

    testWidgets('Il click su "Elimina" nel dialog rimuove il contatto', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockRepo.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Via',
          email: 'via@via.com',
          phoneNumber: '0001',
        ),
      ];
      await viewModel.loadContacts.execute();
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      // Apriamo il dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirmiamo l'eliminazione
      // Ci sono due widget con 'Elimina': il titolo del dialog e il pulsante.
      // Usiamo il finder per il pulsante ElevatedButton.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Elimina'));
      await tester.pumpAndSettle();

      // Il dialog è chiuso e la lista è vuota
      expect(find.text('Elimina Contatto'), findsNothing);
      expect(viewModel.contacts, isEmpty);
    });
    testWidgets('Il click su un contatto apre il modulo di modifica', (
      WidgetTester tester,
    ) async {
      // Arrange
      mockRepo.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Mario Rossi',
          email: 'mario@email.com',
          phoneNumber: '123',
        ),
      ];
      await viewModel.loadContacts.execute();
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      // Act: tap sulla riga del contatto
      await tester.tap(find.text('Mario Rossi'));
      await tester.pumpAndSettle();

      // Assert: il form di modifica è apparso
      expect(find.text('Modifica Contatto'), findsOneWidget);
      expect(find.text('Aggiorna contatto'), findsOneWidget);
    });
  });
}
