import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

void main() {
  Note sampleNote = ProxyNote(
    "0",
    "Nota test 1",
    DateTime.parse("2026-04-14 10:00:30"),
    DateTime.parse("2026-04-14 18:00:30"),
  );
  group("ProxyNote e LocalNote", () {
    test("load() carica correttamente la LocalNote associata", () async {
      await sampleNote.load();
      expect(sampleNote.getElementCount(), 1);
      expect(sampleNote.getNoteElements().first.getContent(), "Nota di prova");
    });

    test(
      "Setter aggiorna correttamente i titoli della nota dopo il load()",
      () async {
        await sampleNote.load();
        sampleNote.setTitle("different");
        expect(sampleNote.getTitle(), "different");
      },
    );

    test(
      "addElement e removeElement funzionano correttamente sulla LocalNote dopo il load()",
      () async {
        await sampleNote.load();
        NoteElement sampleElement = NoteTextElement("rnd");
        sampleNote.addElement(sampleElement, 1);
        expect(sampleNote.getElementCount(), 2);
        expect(sampleNote.getNoteElements()[1].getContent(), "rnd");
        sampleNote.removeElement(sampleElement);
        expect(sampleNote.getElementCount(), 1);
      },
    );

    test(
      "editNoteElement modifica correttamente il contenuto di un NoteElement",
      () async {
        await sampleNote.load();
        NoteElement sampleElement = NoteTextElement("rnd");
        sampleNote.addElement(sampleElement, 1);
        sampleNote.editNoteElement(sampleElement, "not rnd");
        expect(sampleElement.getContent(), "not rnd");
      },
    );
  });
}
