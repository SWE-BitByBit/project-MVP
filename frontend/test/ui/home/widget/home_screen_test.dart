import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_dashboard_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/auth_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';

/// Punto di ingresso per i test di integrazione UI della HomeScreen.
void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: '''
COGNITO_DOMAIN=test.auth.eu-central-1.amazoncognito.com
COGNITO_CLIENT_ID=test_id
COGNITO_CLIENT_SECRET=test_secret
''');
  });

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
            child: HomeScreenView(
              authRepository: AuthRepository(AuthService()),
            ),
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
