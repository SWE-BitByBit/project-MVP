import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

void main() {
  group("Note domain model", () {
    test("Costruttore e getter funzionano correttamente", () {
      Note sample = ProxyNote(
        "random",
        "such title",
        DateTime.parse("2025-01-01 10:30:00"),
        DateTime.parse("2026-02-03 15:32:00"),
        DiaryType.realDiary,
      );
      expect(sample.getId(), "random");
      expect(sample.getTitle(), "such title");
      expect(sample.getCreationDate(), DateTime.parse("2025-01-01 10:30:00"));
      expect(sample.getUpdateDate(), DateTime.parse("2026-02-03 15:32:00"));
    });

    test("Setter funzione correttamente", () {
      Note sample = ProxyNote(
        "random",
        "such title",
        DateTime.parse("2025-01-01 10:30:00"),
        DateTime.parse("2026-02-03 15:32:00"),
        DiaryType.realDiary,
      );
      sample.setTitle("much title");
      expect(sample.getTitle(), "much title");
    });

    test(
      "updateLastModified aggiorna correttamente la data di ultima modifica",
      () {
        Note sample = ProxyNote(
          "random",
          "such title",
          DateTime.parse("2025-01-01 10:30:00"),
          DateTime.parse("2026-02-03 15:32:00"),
          DiaryType.realDiary,
        );
        sample.updateLastModified();
        expect(
          DateFormat("d/M/y H:mm").format(sample.getUpdateDate()),
          DateFormat("d/M/y H:mm").format(DateTime.now()),
        );
      },
    );
  });
}
