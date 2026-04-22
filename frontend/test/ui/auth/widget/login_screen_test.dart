import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/login_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/header_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/google_login_button_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/logged_in_banner_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/user.dart';
import '../../../../testing/mocks/mock_auth_repository.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  Widget createLoginScreen() {
    return MaterialApp(
      home: LoginScreen(authRepository: mockRepository),
    );
  }

  group('LoginScreen Widget Test', () {
    testWidgets('Deve mostrare HeaderWidget e GoogleLoginButtonWidget per utente non loggato', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pump(); // Per permettere al ListenableBuilder di stabilizzarsi

      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(find.byType(GoogleLoginButtonWidget), findsOneWidget);
      expect(find.byType(LoggedInBannerWidget), findsNothing);
    });

    testWidgets('Deve mostrare LoggedInBannerWidget e pulsante Disconnetti per utente già loggato', (WidgetTester tester) async {
      // Arrange
      mockRepository.setMockedUser(const User(
        sub: '1',
        email: 'logged@example.com',
        name: 'Logged',
        surname: 'User',
        idToken: 'i',
        accessToken: 'a',
      ));

      await tester.pumpWidget(createLoginScreen());
      await tester.pump();

      expect(find.byType(LoggedInBannerWidget), findsOneWidget);
      expect(find.text('logged@example.com'), findsOneWidget);
      expect(find.text('Disconnetti'), findsOneWidget);
      expect(find.byType(GoogleLoginButtonWidget), findsNothing);
    });

    testWidgets('Il click su GoogleLoginButton avvia la procedura di login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pump();

      await tester.tap(find.byType(GoogleLoginButtonWidget));
      await tester.pump(); 

      // Dopo il tap, il mock dovrebbe aver impostato un utente (successo di default)
      expect(mockRepository.isLoggedIn(), isTrue);
      
      await tester.pump(); // Notifica la UI
      expect(find.byType(LoggedInBannerWidget), findsOneWidget);
    });

    testWidgets('Il click su Disconnetti effettua il logout', (WidgetTester tester) async {
      // Arrange: partiamo loggati
      mockRepository.setMockedUser(const User(
        sub: '1',
        email: 'a@a.com',
        name: 'A',
        surname: 'S',
        idToken: 'i',
        accessToken: 'a',
      ));

      await tester.pumpWidget(createLoginScreen());
      await tester.pump();

      await tester.tap(find.text('Disconnetti'));
      await tester.pump();

      expect(mockRepository.isLoggedIn(), isFalse);
      expect(find.byType(GoogleLoginButtonWidget), findsOneWidget);
    });

    testWidgets('Mostra messaggio di errore in caso di fallimento login', (WidgetTester tester) async {
      // Arrange
      mockRepository.shouldThrowError = true;

      await tester.pumpWidget(createLoginScreen());
      await tester.pump();

      await tester.tap(find.byType(GoogleLoginButtonWidget));
      await tester.pump(); // Aspetta il completamento dell'operazione asincrona

      // Nota: il viewModel cattura l'eccezione e imposta errorMessage
      expect(find.textContaining('Autenticazione fallita'), findsOneWidget);
    });
  });
}
