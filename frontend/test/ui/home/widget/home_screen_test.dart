import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_dashboard_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';

void main() {
  group('HomeScreen (Integration UI Test)', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    /// Helper: monta HomeScreenView con il provider già iniettato.
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HomeViewModel>.value(
            value: viewModel,
            child: const HomeScreenView(),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il titolo "Home" nella AppBar', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Deve montare il HomeDashboardWidget nel body', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(HomeDashboardWidget), findsOneWidget);
    });

    testWidgets('Deve mostrare il FloatingActionButton per le azioni rapide', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('Non deve mostrare il banner di errore a schermo pulito', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
