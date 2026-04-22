import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';

class MockNoteRepository implements NoteRepository {
  bool shouldThrowError = false;
  Duration simulatedDelay = Duration.zero;
  List<Note> mockedPreviewsToReturn = [];
  LocalNote? mockCreatedNote;

  @override
  Future<void> deleteNote(DiaryType targetDiary, Note note) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante deleteNote');
    }
    // In caso di successo non fa nulla
  }

  @override
  Future<Note> getNoteById(DiaryType targetDiary, String noteId) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante getNoteById');
    }
    return mockCreatedNote!;
  }

  @override
  Future<List<Note>> getNotes(DiaryType targetDiary) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante getNotes');
    }
    return mockedPreviewsToReturn;
  }

  @override
  Future<void> saveNote(DiaryType targetDiary, Note note) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante saveNote');
    }
  }
}
