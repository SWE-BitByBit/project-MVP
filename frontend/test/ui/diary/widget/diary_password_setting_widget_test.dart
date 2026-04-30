import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_password_setting_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockViewModel;
  late ValueNotifier<String?> asyncErrorNotifier;

  setUp(() {
    mockViewModel = MockDiaryAccessViewModel();
    asyncErrorNotifier = ValueNotifier<String?>(null);

    // Stubbing dei getter e metodi base
    when(() => mockViewModel.passwordError).thenReturn('');
    when(() => mockViewModel.setupSuccess).thenReturn(false);
    when(() => mockViewModel.asyncError).thenReturn(asyncErrorNotifier);
    when(() => mockViewModel.validateInput(any())).thenReturn(null);
    when(() => mockViewModel.resetFormState()).thenReturn(null);
  });

  // Helper per creare il widget con un Navigator che supporti il pop()
  Widget createWidgetUnderTest({bool isModifyingRealPassword = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<DiaryAccessViewModel>.value(
                  value: mockViewModel,
                  child: DiaryPasswordSettingWidget(isModifyingRealPassword: isModifyingRealPassword),
                ),
              ),
            ),
            child: const Text('Launch'),
          ),
        ),
      ),
    );
  }

  // Helper per "entrare" nella schermata di test
  Future<void> navigateToWidget(WidgetTester tester) async {
    await tester.tap(find.text('Launch'));
    await tester.pumpAndSettle();
  }

  group('DiaryPasswordSettingWidget', () {
    testWidgets('Visualizza i titoli e le label corrette per la password reale', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isModifyingRealPassword: true));
      await navigateToWidget(tester);

      expect(find.text('Modifica Password Reale'), findsOneWidget);
      expect(find.text('Nuova password reale'), findsOneWidget);
    });

    testWidgets('Visualizza i titoli e le label corrette per la password fittizia', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isModifyingRealPassword: false));
      await navigateToWidget(tester);

      expect(find.text('Password Diario Fittizio'), findsOneWidget);
    });

    testWidgets('Mostra errore se le password inserite non coincidono (validazione locale)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await navigateToWidget(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Nuova password fittizia'), 'pass123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Reinserire Nuova password fittizia'), 'pass456');
      await tester.pump();

      expect(find.text("Le password non combaciano.\n"), findsOneWidget);
    });

    testWidgets('Esegue updateRealPassword se i dati sono validi e isModifyingRealPassword è true', (tester) async {
      when(() => mockViewModel.updateRealPassword(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(isModifyingRealPassword: true));
      await navigateToWidget(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Password diario reale attuale'), 'old_pwd');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nuova password reale'), 'new_pwd');
      await tester.enterText(find.widgetWithText(TextFormField, 'Reinserire Nuova password reale'), 'new_pwd');

      await tester.tap(find.text('Imposta password'));
      await tester.pump();

      verify(() => mockViewModel.updateRealPassword('old_pwd', 'new_pwd')).called(1);
    });

    testWidgets('Mostra SnackBar e chiude al successo del salvataggio', (tester) async {
      when(() => mockViewModel.submitFakePassword(any(), any())).thenAnswer((_) async {});
      when(() => mockViewModel.setupSuccess).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest(isModifyingRealPassword: false));
      await navigateToWidget(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Password diario reale attuale'), 'pwd');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nuova password fittizia'), 'fake');
      await tester.enterText(find.widgetWithText(TextFormField, 'Reinserire Nuova password fittizia'), 'fake');

      await tester.tap(find.text('Imposta password'));

      // Pump manuali per gestire l'ordine: async call -> pop -> snackbar
      await tester.pump(); // Avvia async
      await tester.pump(); // Esegue logic dopo await
      await tester.pump(const Duration(milliseconds: 500)); // Anima pop e snackbar

      expect(find.text("Password impostata con successo."), findsOneWidget);
      verify(() => mockViewModel.resetFormState()).called(1);

      // Verifica che siamo tornati alla schermata precedente (il bottone Launch è di nuovo visibile)
      expect(find.text('Launch'), findsOneWidget);
    });

    testWidgets('Il tasto chiusura dell\'AppBar resetta lo stato e chiude la schermata', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await navigateToWidget(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      verify(() => mockViewModel.resetFormState()).called(1);
      expect(find.text('Launch'), findsOneWidget);
    });
  });
}