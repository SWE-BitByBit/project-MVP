import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

import '../../../testing/mocks/mock_note_service.dart';

void main() {
  group("NoteRepository", () {
    late MockNoteService mockService;
    late NoteRepository repository;
    setUp(() {
      mockService = MockNoteService();
      repository = NoteRepository(mockService);
    });
    test("getNotes mappa correttamente il JSON in oggetti Note", () async {
      mockService.mockedNotesJson = [
        {
          "id": "aaaaaaa",
          "title": "MockNote",
          "creationDate": "2026-02-11 10:00:00",
          "lastModified": "2026-04-14 18:00:30",
        },
        {
          "id": "ffsafad",
          "title": "Second mock note",
          "creationDate": "2025-12-19 15:20:35",
          "lastModified": "2026-04-14 16:00:30",
        },
      ];

      final notes = await repository.getNotes(DiaryType.realDiary);
      expect(notes.length, 2);
      expect(notes.first.getId(), "aaaaaaa");
      expect(notes.first.getTitle(), "MockNote");
      expect(
        notes.first.getCreationDate(),
        DateTime.parse("2026-02-11 10:00:00"),
      );
      expect(
        notes.first.getUpdateDate(),
        DateTime.parse("2026-04-14 18:00:30"),
      );

      mockService.mockedFullNotesJson = [
        {
          "id": "aaaaaaa",
          "title": "MockNote",
          "creationDate": "2026-02-11 10:00:00",
          "lastModified": "2026-04-14 18:00:30",
          "elements": [
            {"type": "text", "content": "Nota di prova con due elementi"},
            {"type": "text", "content": "Secondo elemento"},
          ],
        },
        {
          "id": "ffsafad",
          "title": "Second mock note",
          "creationDate": "2025-12-19 15:20:35",
          "lastModified": "2026-04-14 16:00:30",
          "elements": [
            {"type": "text", "content": "1 element"},
          ],
        },
      ];

      final fullNotes = await repository.getNotes(DiaryType.fakeDiary);
      expect(fullNotes.length, 2);
      expect(fullNotes.first.getElementCount(), 2);
      expect(
        fullNotes.first.getNoteElements().first.getContent(),
        "Nota di prova con due elementi",
      );
      expect(fullNotes.first.getNoteElements().first.getType(), "text");
    });

    test(
      "getNoteById mappa correttamente il JSON in un oggetto Note",
      () async {
        mockService.mockedFullNoteJson = {
          "id": "aaaaaaa",
          "title": "MockNote",
          "creationDate": "2026-02-11 10:00:00",
          "lastModified": "2026-04-14 18:00:30",
          "elements": [
            {"type": "text", "content": "Nota di prova con due elementi"},
            {"type": "text", "content": "Secondo elemento"},
          ],
        };

        final idNote = await repository.getNoteById(
          DiaryType.realDiary,
          "aaaaaaa",
        );
        expect(idNote.getId(), "aaaaaaa");
        expect(idNote.getTitle(), "MockNote");
        expect(idNote.getCreationDate(), DateTime.parse("2026-02-11 10:00:00"));
        expect(idNote.getUpdateDate(), DateTime.parse("2026-04-14 18:00:30"));
        expect(idNote.getElementCount(), 2);
        expect(
          idNote.getNoteElements().first.getContent(),
          "Nota di prova con due elementi",
        );
      },
    );

    test("saveNote completa senza eccezioni in caso di successo", () async {
      ProxyNote mockNote = ProxyNote(
        "id",
        "title",
        DateTime.parse("2026-02-11 10:00:00"),
        DateTime.parse("2026-02-11 10:00:00"),
        DiaryType.realDiary,
      );
      await expectLater(
        repository.saveNote(DiaryType.realDiary, mockNote),
        completes,
      );
    });

    test("deleteNote completa senza eccezioni in caso di successo", () async {
      ProxyNote mockNote = ProxyNote(
        "id",
        "title",
        DateTime.parse("2026-02-11 10:00:00"),
        DateTime.parse("2026-02-11 10:00:00"),
        DiaryType.realDiary,
      );
      await expectLater(
        repository.deleteNote(DiaryType.realDiary, mockNote),
        completes,
      );
    });
  });
}
