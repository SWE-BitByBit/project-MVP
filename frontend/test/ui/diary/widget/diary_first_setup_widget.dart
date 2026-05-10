import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart' hide MockCommand;

import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_first_setup_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockViewModel;
  late MockCommand<String, void> mockCreateInitialPasswordCommand;
  late ValueNotifier<bool> createPasswordIsRunning;
  late ValueNotifier<CommandError<String>?> createPasswordErrors;

  setUp(() {
    mockViewModel = MockDiaryAccessViewModel();
    mockCreateInitialPasswordCommand = MockCommand<String, void>();

    createPasswordIsRunning = ValueNotifier<bool>(false);
    createPasswordErrors = ValueNotifier<CommandError<String>?>(null);

    // Setup ViewModel
    when(() => mockViewModel.createInitialPassword).thenReturn(mockCreateInitialPasswordCommand);
    when(() => mockViewModel.passwordError).thenReturn('');
    when(() => mockViewModel.validateInput(any())).thenReturn(null);

    // Setup Command
    when(() => mockCreateInitialPasswordCommand.isRunning).thenReturn(createPasswordIsRunning);
    when(() => mockCreateInitialPasswordCommand.errors).thenReturn(createPasswordErrors);
    when(() => mockCreateInitialPasswordCommand.run(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<DiaryAccessViewModel>.value(
          value: mockViewModel,
          child: const DiaryFirstSetupWidget(),
        ),
      ),
    );
  }

  group('DiaryFirstSetupWidget', () {
    testWidgets('Visualizza correttamente i campi di input e il messaggio di benvenuto', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Benvenuto!'), findsOneWidget);
      expect(find.text('Crea Password Principale'), findsOneWidget);
      expect(find.text('Conferma Password'), findsOneWidget);
      expect(find.text('Attiva Diario'), findsOneWidget);
    });

    testWidgets('Chiama validateInput quando il testo della password cambia', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Crea Password Principale'), 'NuovaPassword123');

      verify(() => mockViewModel.validateInput('NuovaPassword123')).called(1);
    });

    testWidgets('Mostra il messaggio di errore se passwordError non è vuoto', (tester) async {
      when(() => mockViewModel.passwordError).thenReturn('Password troppo debole');

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Password troppo debole'), findsOneWidget);
      final errorText = tester.widget<Text>(find.text('Password troppo debole'));
      expect(errorText.style?.color, Colors.red);
    });

    testWidgets('Mostra SnackBar se le password non coincidono al click', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Crea Password Principale'), 'pwd123');
      await tester.enterText(find.widgetWithText(TextField, 'Conferma Password'), 'pwd456');

      await tester.tap(find.text('Attiva Diario'));
      await tester.pump(); // Avvia l'animazione della SnackBar

      expect(find.text('Le password non coincidono'), findsOneWidget);
      verifyNever(() => mockCreateInitialPasswordCommand.run(any()));
    });

    testWidgets('Esegue il comando createInitialPassword se le password coincidono', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Crea Password Principale'), 'password_sicura');
      await tester.enterText(find.widgetWithText(TextField, 'Conferma Password'), 'password_sicura');

      await tester.tap(find.text('Attiva Diario'));
      await tester.pump();

      verify(() => mockCreateInitialPasswordCommand.run('password_sicura')).called(1);
    });
  });
}