import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/note_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';

void main() {
  group('NoteDTO', () {
    final sampleJsonIncomplete = {
      "id": "0",
      "title": "Nota test 1",
      "creationDate": "2026-04-14 10:00:30",
      "lastModified": "2026-04-14 18:00:30",
    };
    final sampleJsonFull = {
      "id": "0",
      "title": "Nota test 1",
      "creationDate": "2026-04-14 10:00:30",
      "lastModified": "2026-04-14 18:00:30",
      "elements": [
        {"type": "text", "content": "Nota di prova"},
      ],
    };
    test(
      "fromJson crea correttamente un oggetto ProxyNote da un json senza chiave elements",
      () {
        final sampleProxy = NoteDTO().fromJson(
          sampleJsonIncomplete,
          DiaryType.realDiary,
        );
        expect(sampleProxy.getId(), "0");
        expect(sampleProxy.getTitle(), "Nota test 1");
        expect(
          sampleProxy.getCreationDate(),
          DateTime.parse("2026-04-14 10:00:30"),
        );
        expect(
          sampleProxy.getUpdateDate(),
          DateTime.parse("2026-04-14 18:00:30"),
        );
      },
    );
    test(
      "fromJson crea correttamente un oggetto LocalNote da un json completo",
      () {
        final sampleLocal = NoteDTO().fromJson(
          sampleJsonFull,
          DiaryType.realDiary,
        );
        expect(sampleLocal.getId(), "0");
        expect(sampleLocal.getTitle(), "Nota test 1");
        expect(
          sampleLocal.getCreationDate(),
          DateTime.parse("2026-04-14 10:00:30"),
        );
        expect(
          sampleLocal.getUpdateDate(),
          DateTime.parse("2026-04-14 18:00:30"),
        );
        final sampleElements = sampleLocal.getNoteElements();
        expect(sampleElements[0].getContent(), "Nota di prova");
        expect(sampleElements[0].getType(), "text");
      },
    );
    test("toJson crea una mappa JSON corretta", () {
      final sampleLocal = LocalNote(
        "sample",
        "sample title",
        DateTime.parse("2026-04-14 18:00:30"),
        DateTime.parse("2026-04-14 10:00:30"),
      );
      NoteElement sampleElement = NoteTextElement("sample element");
      sampleLocal.addElement(sampleElement, 0);

      final json = NoteDTO().toJson(sampleLocal);
      expect(json["id"], "sample");
      expect(json["title"], "sample title");
      expect(json["creationDate"], DateTime.parse("2026-04-14 18:00:30"));
      expect(json["lastModified"], DateTime.parse("2026-04-14 10:00:30"));
      expect(json["elements"][0], {
        "content": "sample element",
        "type": "text",
      });
    });
  });
}
