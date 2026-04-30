import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/password_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockVm;
  late MockCommand<String, void> mockLoginCommand;

  setUp(() {
    mockVm = MockDiaryAccessViewModel();
    mockLoginCommand = MockCommand<String, void>();

    // Stubbing dei membri interni del comando
    when(() => mockLoginCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockLoginCommand.canExecute).thenReturn(ValueNotifier<bool>(true));
    when(() => mockLoginCommand.run(any())).thenReturn(null);

    // Stubbing del ViewModel
    when(() => mockVm.login).thenReturn(mockLoginCommand);
    when(() => mockVm.asyncError).thenReturn(ValueNotifier<String?>(null));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<DiaryAccessViewModel>.value(
        value: mockVm,
        child: PasswordFormWidget(onDismiss: () {}),
      ),
    );
  }

  group('PasswordFormWidget - UI Rendering', () {
    testWidgets('visualizza correttamente tutti gli elementi grafici', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Accedi al diario'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Accedi'), findsOneWidget);
    });
  });

  group('PasswordFormWidget - Interactions', () {
    testWidgets('cliccando il pulsante Accedi chiama vm.login.run con la password inserita', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      const testPassword = 'secret_password_123';
      await tester.enterText(find.byType(TextField), testPassword);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => mockLoginCommand.run(testPassword)).called(1);
    });

    testWidgets('premendo invio sulla tastiera chiama vm.login.run', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      const testPassword = 'keyboard_submit_pwd';
      await tester.enterText(find.byType(TextField), testPassword);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(() => mockLoginCommand.run(testPassword)).called(1);
    });
  });

  group('PasswordFormWidget - Error Handling', () {
    testWidgets('mostra uno SnackBar quando viene emesso un errore asincrono', (tester) async {
      // Creiamo un ValueNotifier reale per testare il listener
      final errorNotifier = ValueNotifier<String?>(null);
      when(() => mockVm.asyncError).thenReturn(errorNotifier);

      await tester.pumpWidget(createWidgetUnderTest());

      // Simuliamo l'errore
      const errorMessage = 'Password errata, riprova.';
      errorNotifier.value = errorMessage;

      // Pump per far scattare il listener e la visualizzazione dello SnackBar
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);

      // Verifica che il widget abbia resettato l'errore nel ViewModel (come da codice sorgente)
      expect(errorNotifier.value, isNull);
    });
  });
}