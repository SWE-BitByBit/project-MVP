import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_password_setting_widget.dart';
import 'package:provider/provider.dart';
import '../../../../testing/mocks/mock_diary_account_repository.dart';
import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("DiaryPasswordSettingWidget - UI Integration Test", () {
    late MockNoteRepository mockRepo;
    late MockDiaryAccountRepository mockAccRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      mockAccRepo = MockDiaryAccountRepository();
      viewmodel = DiaryViewmodel(mockRepo, mockAccRepo);
    });

    Future<void> pumpSetter(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiaryViewmodel>.value(
            value: viewmodel,
            child: const DiaryPasswordSettingWidget(),
          ),
        ),
      );
    }

    testWidgets(
      "Inserire una password con errori nel TextFormField per la nuova password mostra una stringa con l'errore rilevato",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();
        final realPwField = find.ancestor(
          of: find.text("Password diario reale"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(realPwField, "real");
        await tester.pumpAndSettle();
        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!S4mP LpwD!");
        await tester.pumpAndSettle();

        expect(find.text("La password non può contenere spazi.\n"), findsOne);
      },
    );

    testWidgets(
      "Inserire una password senza errori nel TextFormField per la nuova password non mostra righe con errori",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();
        final realPwField = find.ancestor(
          of: find.text("Password diario reale"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(realPwField, "real");
        await tester.pumpAndSettle();
        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        expect(
          find.text("La password non può contenere spazi.\n"),
          findsNothing,
        );
      },
    );

    testWidgets(
      "Inserire una password diversa nel TextFormField dove va ripetuta la nuova password fa apparire una riga con un errore",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();
        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        final repeatNewPwField = find.ancestor(
          of: find.text("Reinserire password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        await tester.enterText(repeatNewPwField, "!S4mPLpwD!aa");
        await tester.pumpAndSettle();

        expect(find.text("Le password non combaciano.\n"), findsOne);
      },
    );

    testWidgets(
      "Non inserire la password del diario reale e premere il bottone per il submit fa apparire un errore",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();

        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        final repeatNewPwField = find.ancestor(
          of: find.text("Reinserire password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        await tester.enterText(repeatNewPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text("Inserire password del diario reale.\n"), findsOne);
      },
    );

    testWidgets(
      "Inserire una password del diario fittizio con errori e premere il bottone per il submit non fa apparire il banner di successo",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();
        final realPwField = find.ancestor(
          of: find.text("Password diario reale"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(realPwField, "real");

        await tester.pumpAndSettle();
        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        final repeatNewPwField = find.ancestor(
          of: find.text("Reinserire password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!SamPLpwD!");
        await tester.pumpAndSettle();
        await tester.enterText(repeatNewPwField, "!SamPLpwD!");
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text("Password impostata con successo.\n"), findsNothing);
        expect(
          find.text("La password deve contenere almeno un numero.\n"),
          findsOne,
        );
      },
    );

    testWidgets(
      "Inserire correttamente tutte le password richieste e premere l'ElevatedButton fa apparire un banner che conferma il successo dell'operazione",
      (WidgetTester tester) async {
        await pumpSetter(tester);
        await tester.pumpAndSettle();
        final realPwField = find.ancestor(
          of: find.text("Password diario reale"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(realPwField, "real");

        await tester.pumpAndSettle();
        final newPwField = find.ancestor(
          of: find.text("Nuova password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        final repeatNewPwField = find.ancestor(
          of: find.text("Reinserire password diario fittizio"),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(newPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        await tester.enterText(repeatNewPwField, "!S4mPLpwD!");
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text("Password impostata con successo.\n"), findsOne);
      },
    );
  });
}
