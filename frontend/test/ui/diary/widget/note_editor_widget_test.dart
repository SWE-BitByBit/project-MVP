import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_audio_player_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("NoteEditorWidget Widget Test", () {
    late MockNoteRepository mockRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      viewmodel = DiaryViewmodel(mockRepo);
    });

    Future<void> pumpEditorWidget(
      WidgetTester tester, {
      required VoidCallback onDismiss,
      required Note note,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryViewmodel>.value(
              value: viewmodel,
              child: NoteEditorWidget(onDismiss: onDismiss, selectedNote: note),
            ),
          ),
        ),
      );
    }

    testWidgets("Il widget visualizza correttamente la nota selezionata", (
      WidgetTester tester,
    ) async {
      /// Necessario che la DiarySession sia attiva
      final session = DiarySession.session;
      session.initSession(DiaryType.realDiary);
      Note sampleNote = LocalNote(
        "id",
        "sample title",
        DateTime.parse("2026-04-14 18:00:30"),
        DateTime.parse("2026-04-14 18:00:30"),
      );

      NoteElement textElement = NoteTextElement("sample text");
      NoteElement imageElement = NoteImageElement("/fake_path");
      NoteElement audioElement = NoteAudioElement("/second_path");

      sampleNote.addElement(textElement, sampleNote.getElementCount());
      sampleNote.addElement(imageElement, sampleNote.getElementCount());
      sampleNote.addElement(audioElement, sampleNote.getElementCount());

      mockRepo.mockCreatedNote = sampleNote;
      mockRepo.mockedPreviewsToReturn = [sampleNote];

      await viewmodel.loadPreviews(DiaryType.realDiary);
      await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
      await tester.pumpAndSettle();

      expect(find.text("sample title"), findsOne);
      expect(find.text("sample text"), findsOne);
      expect(find.byType(Image), findsOne);
      expect(find.byType(NoteAudioPlayerWidget), findsOne);

      session.endSession();
    });

    testWidgets(
      "Il bottone di eliminazione rimuove correttamente un elemento dalla nota",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        NoteElement textElement = NoteTextElement("sample text");

        sampleNote.addElement(textElement, sampleNote.getElementCount());

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        viewmodel.loadNote(0);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();
        expect(sampleNote.getElementCount(), 1);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        expect(find.text("sample text"), findsNothing);
        expect(sampleNote.getElementCount(), 0);
        session.endSession();
      },
    );

    testWidgets(
      "Il widget visualizza correttamente il FloatingActionButton per l'aggiunta degli elementi",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOne);
        expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);

        session.endSession();
      },
    );

    testWidgets(
      "Premere il FloatingActionButton per l'aggiunta degli elementi mostra tre PopupMenuItem.",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuItem), findsExactly(3));
        expect(find.text("Aggiungi testo"), findsOne);
        expect(find.text("Aggiungi immagine"), findsOne);
        expect(find.text("Aggiungi traccia audio"), findsOne);

        session.endSession();
      },
    );

    testWidgets(
      "Premere il PopupMenuItem 'Aggiungi testo' aggiunge un elemento testuale vuoto alla nota",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();

        expect(sampleNote.getElementCount(), 0);

        /// Simula click bottone aggiunta
        await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Aggiungi testo"));
        await tester.pumpAndSettle();
        expect(sampleNote.getElementCount(), 1);
        expect(sampleNote.getNoteElements().first.getType(), "text");

        session.endSession();
      },
    );

    /// Non riesco a capire come testare image picker e file picker
    /*testWidgets(
      "Premere il PopupMenuItem 'Aggiungi immagine' aggiunge un elemento immagine alla nota",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();

        expect(sampleNote.getElementCount(), 0);

        /// Simula click bottone aggiunta
        await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Aggiungi immagine"));
        await tester.pumpAndSettle();

        expect(sampleNote.getElementCount(), 1);
        expect(sampleNote.getNoteElements().first.getType(), "image");

        session.endSession();
      },
    );

    testWidgets(
      "Premere il PopupMenuItem 'Aggiungi traccia audio' aggiunge un elemento audio alla nota",
      (WidgetTester tester) async {
        /// Necessario che la DiarySession sia attiva
        final session = DiarySession.session;
        session.initSession(DiaryType.realDiary);
        Note sampleNote = LocalNote(
          "id",
          "sample title",
          DateTime.parse("2026-04-14 18:00:30"),
          DateTime.parse("2026-04-14 18:00:30"),
        );

        mockRepo.mockCreatedNote = sampleNote;
        mockRepo.mockedPreviewsToReturn = [sampleNote];

        await viewmodel.loadPreviews(DiaryType.realDiary);
        await pumpEditorWidget(tester, onDismiss: () {}, note: sampleNote);
        await tester.pumpAndSettle();

        expect(sampleNote.getElementCount(), 0);

        /// Simula click bottone aggiunta
        await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Aggiungi traccia audio"));
        await tester.pumpAndSettle();
        expect(sampleNote.getElementCount(), 1);
        expect(sampleNote.getNoteElements().first.getType(), "audio");

        session.endSession();
      },
    );*/
  });
}
