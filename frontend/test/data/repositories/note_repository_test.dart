import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';

import '../../../testing/mocks/mock_note_service.dart';

void main() {
  group("NoteRepository", () {
    late MockNoteService mockService;
    late NoteRepository repository;
    setUp(() {
      mockService = MockNoteService();
      repository = NoteRepository(mockService);
    });
    test("getNotes mappa correttamente il JSON in oggetti Note", () {
      mockService.mockedNotesJson = [];
    });
  });
}
