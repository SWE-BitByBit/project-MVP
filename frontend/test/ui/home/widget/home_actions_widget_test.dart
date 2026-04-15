import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_emergency_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';

void main() {
  group('HomeActionsWidget Widget Test', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    /// Helper: monta HomeActionsWidget con Provider.
    Future<void> pumpActionsWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<HomeViewModel>.value(
              value: viewModel,
              child: const HomeActionsWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il FloatingActionButton con la freccia verso l\'alto', (WidgetTester tester) async {
      await pumpActionsWidget(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('Il click sul FAB apre il bottom sheet con HomeEmergencyWidget', (WidgetTester tester) async {
      await pumpActionsWidget(tester);

      // Tapping il pulsante deve aprire il ModalBottomSheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verifichiamo che il pannello di emergenza sia apparso
      expect(find.byType(HomeEmergencyWidget), findsOneWidget);
      expect(find.text('Azioni Rapide'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
    });

    testWidgets('Il click su SOS nel bottom sheet chiude il pannello', (WidgetTester tester) async {
      await pumpActionsWidget(tester);

      // Apriamo il pannello
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeEmergencyWidget), findsOneWidget);

      // Clicchiamo SOS per invocare onDismiss -> Navigator.pop
      await tester.tap(find.text('SOS'));
      await tester.pumpAndSettle();

      // Il pannello deve essersi chiuso
      expect(find.byType(HomeEmergencyWidget), findsNothing);
    });
  });
}
