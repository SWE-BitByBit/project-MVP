import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("DiaryScreen - UI Integration Test", () {
    late MockNoteRepository mockRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      viewmodel = DiaryViewmodel(mockRepo);
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
  });
}
