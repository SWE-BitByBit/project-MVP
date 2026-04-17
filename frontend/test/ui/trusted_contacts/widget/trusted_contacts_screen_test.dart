import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contacts_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/error_indicator.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  group('TrustedContactsScreen (Integration UI Test)', () {
    late MockTrustedContactRepository mockRepo;
    late TrustedContactViewModel viewModel;

    setUp(() {
      mockRepo = MockTrustedContactRepository();
      viewModel = TrustedContactViewModel(mockRepo);
    });

    /// Helper: monta TrustedContactScreenView con il provider già iniettato.
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TrustedContactViewModel>.value(
            value: viewModel,
            child: const TrustedContactScreenView(),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il titolo "Contatti Fidati" nella AppBar', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.text('Contatti Fidati'), findsOneWidget);
    });

    testWidgets('Deve montare il TrustedContactListWidget nel body', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byType(TrustedContactListWidget), findsOneWidget);
    });

    testWidgets(
      'Deve mostrare il FloatingActionButton per aggiungere contatti',
      (WidgetTester tester) async {
        await pumpScreen(tester);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );

    testWidgets('Non deve mostrare il banner di errore a schermo pulito', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
