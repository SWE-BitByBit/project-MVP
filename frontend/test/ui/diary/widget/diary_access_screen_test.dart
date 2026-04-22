import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';

void main() {
  group("DiaryAccessScreen - UI Integration Test", () {
    late MockDiaryAccountRepository mockRepo;
    late DiaryAccessViewmodel viewmodel;

    setUp(() {
      mockRepo = MockDiaryAccountRepository();
      viewmodel = DiaryAccessViewmodel(mockRepo);
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryAccessViewmodel>.value(
              value: viewmodel,
              child: const DiaryAccessScreenView(),
            ),
          ),
        ),
      );
    }

    testWidgets("Non deve mostrare il banner di errore a schermo pulito", (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets("Deve mostrare l'ElevatedButton per il login", (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byType(ElevatedButton), findsOne);
    });
    testWidgets("Deve mostrare il titolo nella AppBar", (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);
      expect(find.text("Accesso al diario"), "Accesso al diario");
    });
    testWidgets(
      'Deve mostrare il banner di errore rosso se il ViewModel ha un errore',
      (WidgetTester tester) async {
        mockRepo.shouldThrowError = true;
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );
  });
}
