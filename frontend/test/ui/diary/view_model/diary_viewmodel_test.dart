import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';

import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("DiaryViewmodel", () {
    late DiaryViewmodel viewmodel;
    late MockNoteRepository repo;
    setUp(() {
      repo = MockNoteRepository();
      viewmodel = DiaryViewmodel(repo);
    });
    group("DiaryViewmodel - Stato iniziale viewmodel", () {
      test("Stato iniziale del viewmodel deve essere pulito", () {
        expect(viewmodel.getCurrentNote(), null);
        expect(viewmodel.getNoteListSize(), 0);
        expect(viewmodel.isLoading(), false);
      });
    });

    group("DiaryViewmodel - Caricamento note", () {
      test(
        "addNewNote deve aggiungere una nota vuota e ricaricare la lista",
        () {
          viewmodel.addNewNote(DiaryType.realDiary);
          expect(viewmodel.getNoteListSize(), 1);
          expect(viewmodel.getSavedNotes().last, isNotNull);
        },
      );
      test("loadPreviews carica correttamente le ProxyNote", () async {
        Note note1 = ProxyNote(
          "0",
          "first",
          DateTime.parse(""),
          DateTime.parse(""),
          DiaryType.realDiary,
        );
        Note note2 = ProxyNote(
          "1",
          "second",
          DateTime.parse(""),
          DateTime.parse(""),
          DiaryType.realDiary,
        );
        Note note3 = ProxyNote(
          "2",
          "third",
          DateTime.parse(""),
          DateTime.parse(""),
          DiaryType.realDiary,
        );
        repo.mockedPreviewsToReturn = [];
        await viewmodel.loadPreviews(DiaryType.realDiary);
      });
    });
  });
}
