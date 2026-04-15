import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  group('TrustedContactActionsWidget Widget Test', () {
    late MockTrustedContactRepository mockRepo;
    late TrustedContactViewModel viewModel;

    setUp(() {
      mockRepo = MockTrustedContactRepository();
      viewModel = TrustedContactViewModel(mockRepo);
    });

    /// Helper: monta TrustedContactActionsWidget con Provider.
    Future<void> pumpActionsWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TrustedContactViewModel>.value(
              value: viewModel,
              child: const TrustedContactActionsWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il FloatingActionButton con l\'icona "+"', (WidgetTester tester) async {
      await pumpActionsWidget(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Il click sul FAB apre il bottom sheet con TrustedContactFormWidget', (WidgetTester tester) async {
      await pumpActionsWidget(tester);

      // Premiamo il FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verifichiamo che il form sia apparso
      expect(find.byType(TrustedContactFormWidget), findsOneWidget);
      expect(find.text('Nuovo Contatto Fidato'), findsOneWidget);
    });
  });
}
