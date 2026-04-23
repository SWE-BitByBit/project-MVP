import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/main.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../testing/mocks/auth/mock_auth_repository.dart';

void main() {
  setUpAll(() {
    // Carichiamo variabili d'ambiente fittizie per evitare errori durante il build del widget
    dotenv.loadFromString(envString: 'COGNITO_DOMAIN=test\nCOGNITO_CLIENT_ID=test');
  });

  group('MainApp Widget Test', () {
    testWidgets('Deve caricare MaterialApp e mostrare HomeScreen come home page', (WidgetTester tester) async {
      // Arrange
      final mockAuthRepository = MockAuthRepository();

      // Act
      await tester.pumpWidget(MainApp(authRepository: mockAuthRepository));
      await tester.pump();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Verifica il tema dell\'app', (WidgetTester tester) async {
      // Arrange
      final mockAuthRepository = MockAuthRepository();

      // Act
      await tester.pumpWidget(MainApp(authRepository: mockAuthRepository));
      
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Assert
      expect(app.title, "L'App che Protegge e Trasforma");
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}
