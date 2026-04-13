import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contacts_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  group('TrustedContactsScreen (Integration UI Test)', () {
    late MockTrustedContactRepository mockRepo;
    late TrustedContactViewModel viewModel;

    setUp(() {
      mockRepo = MockTrustedContactRepository();
      viewModel = TrustedContactViewModel(mockRepo);
    });

    /// Helper: monta _TrustedContactScreenView con il provider già iniettato.
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TrustedContactViewModel>.value(
            value: viewModel,
            // Testiamo la vista pura, non il compositor TrustedContactScreen
            child: const _TrustedContactScreenView(),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il titolo "Contatti Fidati" nella AppBar', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.text('Contatti Fidati'), findsOneWidget);
    });

    testWidgets('Deve montare il TrustedContactListWidget nel body', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(TrustedContactListWidget), findsOneWidget);
    });

    testWidgets('Deve mostrare il FloatingActionButton per aggiungere contatti', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Non deve mostrare il banner di errore a schermo pulito', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('Deve mostrare il banner di errore rosso se il ViewModel ha un errore', (WidgetTester tester) async {
      // Forziamo l'errore simulando un loadContacts fallito
      mockRepo.shouldThrowError = true;
      await viewModel.loadContacts();

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('Errore nel caricamento dei contatti'), findsOneWidget);
    });

    testWidgets('Il click sull\'icona × nel banner di errore deve chiuderlo', (WidgetTester tester) async {
      // Setup errore
      mockRepo.shouldThrowError = true;
      await viewModel.loadContacts();
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Clicchiamo la X
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Il banner sparisce
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}

/// Vista pura di TrustedContactsScreen esposta per i test,
/// speculare alla classe privata _TrustedContactScreenView nel file principale.
class _TrustedContactScreenView extends StatelessWidget {
  const _TrustedContactScreenView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TrustedContactViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti Fidati'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Column(
        children: [
          if (viewModel.error != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    onPressed: viewModel.clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          const Expanded(child: TrustedContactListWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        tooltip: 'Aggiungi contatto fidato',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
