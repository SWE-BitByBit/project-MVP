import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
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
      test("", () {});
    });
  });
}
