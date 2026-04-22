import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_actions_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("NoteActionsWidget Widget Test", () {
    late MockNoteRepository mockRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      viewmodel = DiaryViewmodel(mockRepo);
    });

    Future<void> pumpActionsWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryViewmodel>.value(
              value: viewmodel,
              child: const NoteActionsWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets("Deve mostrare il FloatingActionButton con l'icona '+'", (
      WidgetTester tester,
    ) async {
      await pumpActionsWidget(tester);
      expect(find.byType(FloatingActionButton), findsOne);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("Il click sul bottone aggiunge una nota", (
      WidgetTester tester,
    ) async {
      /// Necessario che la DiarySession sia attiva
      final session = DiarySession.session;
      session.initSession(DiaryType.realDiary);
      await pumpActionsWidget(tester);
      viewmodel.loadPreviews(DiaryType.realDiary);
      expect(viewmodel.getNoteListSize(), 0);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(viewmodel.getNoteListSize(), 1);
      session.endSession();
    });
  });
}
