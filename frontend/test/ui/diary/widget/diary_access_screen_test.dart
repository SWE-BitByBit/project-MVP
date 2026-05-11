import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart' hide MockCommand;

import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/password_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_first_setup_widget.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockViewModel;
  late MockCommand<String, void> mockLoginCommand;
  late MockCommand<String, void> mockCreateInitialPasswordCommand;

  late ValueNotifier<bool> loginIsRunning;
  late ValueNotifier<bool> createPasswordIsRunning;
  late ValueNotifier<CommandError<String>?> loginErrors;
  late ValueNotifier<CommandError<String>?> createPasswordErrors;
  late ValueNotifier<String?> asyncErrorNotifier;

  setUp(() {
    mockViewModel = MockDiaryAccessViewModel();
    mockLoginCommand = MockCommand<String, void>();
    mockCreateInitialPasswordCommand = MockCommand<String, void>();

    loginIsRunning = ValueNotifier<bool>(false);
    createPasswordIsRunning = ValueNotifier<bool>(false);
    loginErrors = ValueNotifier<CommandError<String>?>(null);
    createPasswordErrors = ValueNotifier<CommandError<String>?>(null);
    asyncErrorNotifier = ValueNotifier<String?>(null);

    // Stubbing dei getter richiesti dai widget figli (DiaryFirstSetupWidget e PasswordFormWidget)
    when(() => mockViewModel.passwordError).thenReturn('');
    when(() => mockViewModel.asyncError).thenReturn(asyncErrorNotifier);

    // Setup Comandi
    when(() => mockViewModel.login).thenReturn(mockLoginCommand);
    when(() => mockViewModel.createInitialPassword).thenReturn(mockCreateInitialPasswordCommand);

    when(() => mockLoginCommand.isRunning).thenReturn(loginIsRunning);
    when(() => mockLoginCommand.errors).thenReturn(loginErrors);
    when(() => mockCreateInitialPasswordCommand.isRunning).thenReturn(createPasswordIsRunning);
    when(() => mockCreateInitialPasswordCommand.errors).thenReturn(createPasswordErrors);

    // Default flags
    when(() => mockViewModel.isCheckingStatus).thenReturn(false);
    when(() => mockViewModel.needsInitialSetup).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<DiaryAccessViewModel>.value(
        value: mockViewModel,
        child: const DiaryAccessScreenView(),
      ),
    );
  }

  group('DiaryAccessScreenView', () {
    testWidgets('Mostra CircularProgressIndicator quando isCheckingStatus è true', (tester) async {
      when(() => mockViewModel.isCheckingStatus).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Mostra CircularProgressIndicator quando un comando è in esecuzione', (tester) async {
      loginIsRunning.value = true;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Mostra DiaryFirstSetupWidget quando needsInitialSetup è true', (tester) async {
      when(() => mockViewModel.needsInitialSetup).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(DiaryFirstSetupWidget), findsOneWidget);
      expect(find.text('Configurazione'), findsOneWidget);
    });

    testWidgets('Mostra PasswordFormWidget quando non serve il setup e non sta caricando', (tester) async {
      when(() => mockViewModel.needsInitialSetup).thenReturn(false);
      when(() => mockViewModel.isCheckingStatus).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(PasswordFormWidget), findsOneWidget);
      expect(find.text('Accesso al diario'), findsOneWidget);
    });
  });
}