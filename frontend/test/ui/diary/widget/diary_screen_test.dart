import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';
import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("DiaryScreen - UI Integration Test", () {
    late MockNoteRepository mockRepo;
    late MockDiaryAccountRepository mockAccRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      mockAccRepo = MockDiaryAccountRepository();
      viewmodel = DiaryViewmodel(mockRepo, mockAccRepo);
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DiaryViewmodel>.value(
            value: viewmodel,
            child: const DiaryScreenView(),
          ),
        ),
      );
    }

    testWidgets(
      'Deve mostrare il banner di errore rosso se il ViewModel ha un errore',
      (WidgetTester tester) async {
        mockRepo.shouldThrowError = true;
        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      },
    );

    testWidgets(
      "Deve mostrare il FloatingActionButton per l'aggiunta delle note",
      (WidgetTester tester) async {
        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOne);
        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );

    testWidgets("Deve mostrare il NoteListWidget nel corpo", (
      WidgetTester tester,
    ) async {
      await viewmodel.loadPreviews(DiaryType.realDiary);
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.byType(NoteListWidget), findsOne);
    });

    testWidgets("Deve mostrare il titolo nell'AppBar", (
      WidgetTester tester,
    ) async {
      await viewmodel.loadPreviews(DiaryType.realDiary);
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text("Diario"), findsOne);
    });

    testWidgets(
      "Deve mostrare l'ElevatedButton per accedere all'impostazione della password del diario fittizio solo se l'utente ha effettuato l'accesso al diario reale",
      (WidgetTester tester) async {
        DiarySession session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ElevatedButton), findsOne);
        expect(find.text("Impostazione password diario fittizio"), findsOne);
        session.endSession();
      },
    );

    testWidgets(
      "L'ElevatedButton per accedere all'impostazione della password del diario fittizio apre correttamente il DiaryPasswordSettingWidget",
      (WidgetTester tester) async {
        DiarySession session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.text("Impostazione password diario fittizio"));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsExactly(3));
        expect(find.text("Imposta password"), findsOne);
        session.endSession();
      },
    );
    testWidgets(
      "Non deve mostrare l'ElevatedButton per accedere all'impostazione della password del diario fittizio se l'utente è nel diario fittizio",
      (WidgetTester tester) async {
        DiarySession session = DiarySession.session;
        session.initSession(DiaryType.fakeDiary);
        await viewmodel.loadPreviews(DiaryType.fakeDiary);
        await pumpScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ElevatedButton), findsNothing);
        expect(
          find.text("Impostazione password diario fittizio"),
          findsNothing,
        );
        session.endSession();
      },
    );
  });
}
