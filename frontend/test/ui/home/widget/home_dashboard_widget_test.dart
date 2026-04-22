import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_dashboard_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/dashboard_button_widget.dart';

void main() {
  group('HomeDashboardWidget Widget Test', () {
    late HomeViewModel viewModel;

    setUp(() {
      viewModel = HomeViewModel();
    });

    /// Helper: monta HomeDashboardWidget all'interno di un Provider e MaterialApp.
    Future<void> pumpDashboard(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<HomeViewModel>.value(
              value: viewModel,
              child: const HomeDashboardWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare esattamente 4 DashboardButtonWidget', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.byType(DashboardButtonWidget), findsNWidgets(4));
    });

    testWidgets('Deve mostrare il pulsante "Supporto Chat"', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.text('Supporto Chat'), findsOneWidget);
    });

    testWidgets('Deve mostrare il pulsante "Contatti Fidati"', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.text('Contatti Fidati'), findsOneWidget);
    });

    testWidgets('Deve mostrare il pulsante "Il mio Diario"', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.text('Il mio Diario'), findsOneWidget);
    });

    testWidgets('Deve mostrare il pulsante "Informazioni"', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);
      expect(find.text('Informazioni'), findsOneWidget);
    });

    testWidgets(
      'Deve mostrare il CircularProgressIndicator quando isLoading è true',
      (WidgetTester tester) async {
        // HomeViewModel.isLoading è sempre false, ma sostituiamo con una
        // sottoclasse che lo rende true per testare il ramo del loading.
        final loadingViewModel = _LoadingHomeViewModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChangeNotifierProvider<HomeViewModel>.value(
                value: loadingViewModel,
                child: const HomeDashboardWidget(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(DashboardButtonWidget), findsNothing);
      },
    );
  });
}

/// Sottoclasse di HomeViewModel che espone isLoading = true per i test.
class _LoadingHomeViewModel extends HomeViewModel {
  @override
  bool get isLoading => true;
}
