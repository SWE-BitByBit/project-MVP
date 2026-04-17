import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/trusted_contact.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  group('TrustedContactFormWidget Widget Test', () {
    late MockTrustedContactRepository mockRepo;
    late TrustedContactViewModel viewModel;

    setUp(() {
      mockRepo = MockTrustedContactRepository();
      viewModel = TrustedContactViewModel(mockRepo);
    });

    /// Helper: monta TrustedContactFormWidget con Provider e onDismiss.
    Future<void> pumpFormWidget(
      WidgetTester tester, {
      required VoidCallback onDismiss,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TrustedContactViewModel>.value(
              value: viewModel,
              child: TrustedContactFormWidget(onDismiss: onDismiss),
            ),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il titolo e i tre campi del form', (
      WidgetTester tester,
    ) async {
      await pumpFormWidget(tester, onDismiss: () {});

      expect(find.text('Nuovo Contatto Fidato'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget); // campo nome
      expect(find.byIcon(Icons.phone), findsOneWidget); // campo telefono
      expect(find.byIcon(Icons.email), findsOneWidget); // campo email
      expect(find.text('Salva contatto'), findsOneWidget);
    });

    testWidgets('La validazione deve fallire se i campi sono vuoti', (
      WidgetTester tester,
    ) async {
      await pumpFormWidget(tester, onDismiss: () {});

      // Tocchiamo "Salva contatto" senza compilare nulla
      await tester.tap(find.text('Salva contatto'));
      await tester.pumpAndSettle();

      // Flutter mostra i messaggi di errore di validazione
      expect(find.text('Inserisci il nome'), findsOneWidget);
      expect(find.text('Inserisci il numero di telefono'), findsOneWidget);
      expect(find.text("Inserisci l'email"), findsOneWidget);
    });

    testWidgets(
      'Con i campi validi, deve chiamare createContact e invocare onDismiss',
      (WidgetTester tester) async {
        bool dismissCalled = false;

        // Prepariamo il mock
        mockRepo.mockedCreatedContact = TrustedContact(
          id: 'c-new',
          name: 'Anna Neri',
          email: 'anna@email.com',
          phoneNumber: '+39 333 7654321',
        );
        mockRepo.mockedContactsToReturn = [mockRepo.mockedCreatedContact!];

        await pumpFormWidget(
          tester,
          onDismiss: () {
            dismissCalled = true;
          },
        );

        // Compiliamo i campi
        await tester.enterText(
          find.widgetWithIcon(TextFormField, Icons.person),
          'Anna Neri',
        );
        await tester.enterText(
          find.widgetWithIcon(TextFormField, Icons.phone),
          '+39 333 7654321',
        );
        await tester.enterText(
          find.widgetWithIcon(TextFormField, Icons.email),
          'anna@email.com',
        );

        // Inviamo il form
        await tester.tap(find.text('Salva contatto'));
        await tester.pumpAndSettle();

        // Verifichiamo che il contatto sia stato creato e il dismiss invocato
        expect(viewModel.contacts.length, 1);
        expect(viewModel.contacts.first.getName(), 'Anna Neri');
        expect(
          dismissCalled,
          isTrue,
          reason: 'onDismiss deve essere chiamata dopo il salvataggio',
        );
      },
    );

    testWidgets(
      'In modalità modifica mostra titoli corretti e dati pre-popolati',
      (WidgetTester tester) async {
        final existingContact = TrustedContact(
          id: 'c-1',
          name: 'Mario Rossi',
          email: 'mario@email.com',
          phoneNumber: '123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<TrustedContactViewModel>.value(
                value: viewModel,
                child: TrustedContactFormWidget(
                  onDismiss: () {},
                  initialContact: existingContact,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Modifica Contatto'), findsOneWidget);
        expect(find.text('Mario Rossi'), findsOneWidget);
        expect(find.text('Aggiorna contatto'), findsOneWidget);
      },
    );
  });
}
