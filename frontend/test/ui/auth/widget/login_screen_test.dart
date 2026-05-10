import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/login_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/google_login_button_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/logged_in_banner_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_banner_widget.dart';

import '../../../../testing/mocks/auth/mock_user.dart';
import '../../../../testing/mocks/auth/mock_auth_view_model.dart';

void main() {
  late MockAuthViewModel mockViewModel;
  late MockLoginCommand mockLoginCommand;
  late MockLogoutCommand mockLogoutCommand;
  late MockUser mockUser;

  late ValueNotifier<bool> loginIsRunningNotifier;
  late ValueNotifier<CommandError?> loginErrorsNotifier;

  setUp(() {
    mockViewModel = MockAuthViewModel();
    mockLoginCommand = MockLoginCommand();
    mockLogoutCommand = MockLogoutCommand();
    mockUser = MockUser();

    loginIsRunningNotifier = ValueNotifier<bool>(false);
    loginErrorsNotifier = ValueNotifier<CommandError?>(null);

    // Setup dei command_it
    when(() => mockLoginCommand.isRunning).thenReturn(loginIsRunningNotifier);
    when(() => mockLoginCommand.errors).thenReturn(loginErrorsNotifier);
    when(() => mockLoginCommand.run()).thenAnswer((_) async {});
    when(() => mockLoginCommand.clearErrors()).thenAnswer((_) {});

    when(() => mockLogoutCommand.run()).thenAnswer((_) async {});

    // Setup del ViewModel
    when(() => mockViewModel.login).thenReturn(mockLoginCommand);
    when(() => mockViewModel.logout).thenReturn(mockLogoutCommand);
    when(() => mockViewModel.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthViewModel>.value(
        value: mockViewModel,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('Mostra GoogleLoginButtonWidget se l\'utente NON è loggato', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(GoogleLoginButtonWidget), findsOneWidget);
      expect(find.byType(LoggedInBannerWidget), findsNothing);
      expect(find.text('Disconnetti'), findsNothing);
    });

    testWidgets('Passa isLoading=true al bottone se il comando login è in esecuzione', (tester) async {
      loginIsRunningNotifier.value = true;
      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<GoogleLoginButtonWidget>(find.byType(GoogleLoginButtonWidget));
      expect(button.isLoading, isTrue);
    });

    testWidgets('Mostra ErrorBannerWidget se c\'è un errore nel comando di login', (tester) async {
      loginErrorsNotifier.value = CommandError(error: Exception('Credenziali errate'));
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ErrorBannerWidget), findsOneWidget);
      expect(find.text('Credenziali errate'), findsOneWidget);
    });

    testWidgets('Mostra LoggedInBannerWidget e bottone Disconnetti se l\'utente è loggato', (tester) async {
      when(() => mockUser.email).thenReturn('mario.rossi@example.com');
      when(() => mockViewModel.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LoggedInBannerWidget), findsOneWidget);
      expect(find.text('Disconnetti'), findsOneWidget);
      expect(find.byType(GoogleLoginButtonWidget), findsNothing);
    });

    testWidgets('Il bottone Disconnetti chiama il comando logout', (tester) async {
      when(() => mockUser.email).thenReturn('mario.rossi@example.com');
      when(() => mockViewModel.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Disconnetti'));
      verify(() => mockLogoutCommand.run()).called(1);
    });

    testWidgets('Il GoogleLoginButtonWidget ha la callback collegata al comando run', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = tester.widget<GoogleLoginButtonWidget>(find.byType(GoogleLoginButtonWidget));

      // Eseguiamo la callback esposta dal custom widget
      button.onPressedCallback();

      verify(() => mockLoginCommand.run()).called(1);
    });
  });
}