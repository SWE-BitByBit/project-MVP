import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

void main() {
  group("NoteService", () {
    late NoteService service;

    setUp(() {
      service = NoteService();
    });

    test(
      "fetchNotes restituisce la lista predefinita (placeholder in attesa di backend)",
      () async {
        final sampleJSONs = await service.fetchNotes(DiaryType.realDiary);
        expect(sampleJSONs, isNotEmpty);
        expect(sampleJSONs.length, 3);
        expect(sampleJSONs.first["id"], "0");
      },
    );

    test(
      "fetchNoteById restituisce il JSON predefinito con l'id passato come parametro (placeholder in attesa di backend)",
      () async {
        final idSampleJSON = await service.fetchNoteById("0");
        expect(idSampleJSON["id"], "0");
        expect(idSampleJSON["title"], "Nota test 1");
      },
    );

    test(
      "saveNote completa senza errori (placeholder in attesa di backend)",
      () async {
        expect(service.saveNote({"id": "randomJson"}), completes);
      },
    );

    test(
      "deleteNote completa senza errori (placeholder in attesa di backend)",
      () async {
        expect(service.deleteNote("anyId"), completes);
      },
    );
  });
}
