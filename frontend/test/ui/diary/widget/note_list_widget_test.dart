import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("NoteListWidget Widget Test", () {
    late MockNoteRepository mockRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      viewmodel = DiaryViewmodel(mockRepo);
    });
    Future<void> pumpListWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryViewmodel>.value(
              value: viewmodel,
              child: const NoteListWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets(
      "Stato vuoto: deve mostrare il messaggio 'Nessuna nota presente nel diario'",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        await pumpListWidget(tester);
        viewmodel.loadPreviews(DiaryType.realDiary);
        expect(viewmodel.getNoteListSize(), 0);

        expect(find.text('Nessuna nota presente nel diario'), findsOne);
        session.endSession();
      },
    );

    testWidgets(
      "Il widget mostra correttamente dei ListTile quando la lista delle note non è vuota",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);

        Note sampleNote = LocalNote(
          "id",
          "nota a caso",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );
        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];
        await pumpListWidget(tester);
        viewmodel.loadPreviews(DiaryType.realDiary);
        await tester.pumpAndSettle();
        expect(find.byType(ListTile), findsExactly(1));
        expect(find.text("nota a caso"), findsOne);
        session.endSession();
      },
    );

    testWidgets("Stato loading: deve mostrare il CircularProgressIndicator", (
      WidgetTester tester,
    ) async {
      await pumpListWidget(tester);
      mockRepo.simulatedDelay = const Duration(seconds: 1);
      viewmodel.loadPreviews(DiaryType.realDiary);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      mockRepo.simulatedDelay = Duration.zero;
    });
    testWidgets(
      "Click sul pulsante per l'eliminazione deve mostrare il dialogo di conferma eliminazione.",
      (WidgetTester tester) async {
        Note deletableNote = LocalNote(
          "deletable",
          "very deletable note",
          DateTime.now(),
          DateTime.now(),
        );
        mockRepo.mockedPreviewsToReturn = [deletableNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpListWidget(tester);
        await tester.pumpAndSettle();

        /// Simula click sul bottone
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        /// Verifica presenza dialogo
        expect(find.text('Elimina nota'), findsOneWidget);
        expect(find.text('Annulla'), findsOneWidget);
        expect(find.text('Elimina'), findsOneWidget);
      },
    );
    testWidgets(
      "Nel dialogo di conferma eliminazione, cliccare sul pulsante annulla chiude il dialogo senza eliminare la nota.",
      (WidgetTester tester) async {
        Note deletableNote = LocalNote(
          "deletable",
          "very deletable note",
          DateTime.now(),
          DateTime.now(),
        );
        mockRepo.mockedPreviewsToReturn = [deletableNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpListWidget(tester);
        await tester.pumpAndSettle();

        /// Simula click sul bottone
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        /// Annullamento
        await tester.tap(find.text('Annulla'));
        await tester.pumpAndSettle();

        /// Verifica
        expect(find.text('Elimina nota'), findsNothing);
        expect(viewmodel.getNoteListSize(), 1);
      },
    );
    testWidgets(
      "Nel dialogo di conferma eliminazione, cliccare sul pulsante elimina chiude il dialogo ed elimina la nota.",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note deletableNote = LocalNote(
          "deletable",
          "very deletable note",
          DateTime.now(),
          DateTime.now(),
        );
        mockRepo.mockedPreviewsToReturn = [deletableNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpListWidget(tester);
        await tester.pumpAndSettle();

        /// Simula click sul bottone
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        /// Conferma
        await tester.tap(find.text('Elimina'));
        await tester.pumpAndSettle();

        /// Verifica
        expect(find.text('Elimina nota'), findsNothing);
        expect(viewmodel.getNoteListSize(), 0);
        session.endSession();
      },
    );
    testWidgets("Click su una nota apre l'editor delle note", (
      WidgetTester tester,
    ) async {
      /// Necessario che la DiarySession sia attiva
      final session = DiarySession.session;
      session.initSession(DiaryType.realDiary);

      Note sampleNote = LocalNote(
        "id",
        "nota a caso",
        DateTime.parse("2026-04-14 18:00:30"),
        DateTime.parse("2026-04-14 18:00:30"),
      );
      mockRepo.mockCreatedNote = sampleNote;
      mockRepo.mockedPreviewsToReturn = [sampleNote];

      await viewmodel.loadPreviews(DiaryType.realDiary);
      await pumpListWidget(tester);
      await tester.pumpAndSettle();

      /// Simula click su nota
      await tester.tap(find.text('nota a caso'));
      await tester.pumpAndSettle();

      /// Verifica
      expect(find.byType(NoteEditorWidget), findsOne);

      session.endSession();
    });
  });
}
