import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/password_form_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';

void main() {
  group("PasswordFormWidget Widget Test", () {
    late MockDiaryAccountRepository mockRepo;
    late DiaryAccessViewmodel viewmodel;

    setUp(() {
      mockRepo = MockDiaryAccountRepository();
      viewmodel = DiaryAccessViewmodel(mockRepo);
    });

    Future<void> pumpPwFormWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryAccessViewmodel>.value(
              value: viewmodel,
              child: PasswordFormWidget(onDismiss: () {}),
            ),
          ),
        ),
      );
    }

    testWidgets(
      "Il widget visualizza correttamente il TextField per l'inserimento della password",
      (WidgetTester tester) async {
        await pumpPwFormWidget(tester);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOne);
      },
    );

    testWidgets(
      "Il widget visualizza correttamente l'ElevatedButton per effettuare il tentativo di accesso",
      (WidgetTester tester) async {
        await pumpPwFormWidget(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ElevatedButton), findsOne);
      },
    );

    testWidgets(
      "Il widget apre il NoteListWidget se l'utente accede con la password corretta",
      (WidgetTester tester) async {
        await pumpPwFormWidget(tester);
        await tester.pumpAndSettle();
        final pwdField = find.byType(TextField);
        await tester.enterText(pwdField, "real");
        await tester.pumpAndSettle();
        await tester.tap(find.text("Accedi"));
        await tester.pumpAndSettle();

        expect(find.byType(DiaryScreen), findsOne);
      },
    );
  });
}
