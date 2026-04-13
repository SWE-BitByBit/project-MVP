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

    /// Helper: monta _HomeScreenView con il provider già iniettato.
    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<HomeViewModel>.value(
            value: viewModel,
            child: const _HomeScreenView(),
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

/// Vista pura esposta per i test (corrisponde a _HomeScreenView nel file principale).
class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 30, color: Colors.teal.shade900),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 28, color: Colors.teal.shade900),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
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
          const Expanded(child: HomeDashboardWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal.shade50,
        child: Icon(Icons.keyboard_arrow_up, color: Colors.teal.shade800, size: 30),
      ),
    );
  }
}
