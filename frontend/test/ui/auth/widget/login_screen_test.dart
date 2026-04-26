import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/login_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/header_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/google_login_button_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/logged_in_banner_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';
import '../../../../testing/mocks/auth/mock_auth_repository.dart';

void main() {
  final getIt = GetIt.instance;
  late MockAuthRepository mockRepository;
  late AuthViewModel viewModel;

  setUp(() async {
    // Svuotiamo GetIt prima di ogni test per evitare conflitti
    await getIt.reset();

    // Inizializziamo i mock
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockRepository);

    // Registriamo le dipendenze nel locator che la LoginScreen userà
    getIt.registerSingleton<AuthRepository>(mockRepository);
    getIt.registerSingleton<AuthViewModel>(viewModel);

    // Gestore errori globale per evitare il crash del test (come visto prima)
    Command.globalExceptionHandler = (error, stack) {};
  });

  Widget createLoginScreen() {
    return MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen Widget Test', () {
    testWidgets('Deve mostrare HeaderWidget e GoogleLoginButtonWidget per utente non loggato', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      // pumpAndSettle aspetta che tutte le animazioni e i micro-task siano finiti
      await tester.pumpAndSettle();

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

      // Notifichiamo il viewModel che la sessione esiste
      viewModel.checkExistingSession();

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(LoggedInBannerWidget), findsOneWidget);
      expect(find.text('logged@example.com'), findsOneWidget);
      expect(find.text('Disconnetti'), findsOneWidget);
    });

    testWidgets('Il click su GoogleLoginButton avvia la procedura di login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Tap sul bottone
      await tester.tap(find.byType(GoogleLoginButtonWidget));

      // Importante: pump() avvia l'operazione, pumpAndSettle() aspetta che finisca
      await tester.pump();
      await tester.pumpAndSettle();

      expect(mockRepository.isLoggedIn(), isTrue);
      expect(find.byType(LoggedInBannerWidget), findsOneWidget);
    });

    testWidgets('Mostra messaggio di errore in caso di fallimento login', (WidgetTester tester) async {
      // Arrange
      mockRepository.shouldThrowError = true;

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GoogleLoginButtonWidget));

      // Aspettiamo che il comando fallisca e la UI si aggiorni
      await tester.pumpAndSettle();

      // Verifichiamo che il testo dell'errore (gestito da command_it) appaia
      expect(find.textContaining('Autenticazione fallita'), findsOneWidget);
    });
  });
}