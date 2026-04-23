import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class MockNoteService implements NoteService {
  bool shouldThrowError = false;
  Duration simulatedDelay = Duration.zero;

  /// JSON di risposta restituito da [fetchNotes].
  List<Map<String, dynamic>> mockedNotesJson = [];
  List<Map<String, dynamic>> mockedFullNotesJson = [];

  /// JSON di risposta restituito da [fetchNoteById].
  Map<String, dynamic> mockedFullNoteJson = {};

  @override
  Future<void> deleteNote(String noteId) async {
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante deleteNote');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchNoteById(String noteId) async {
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante fetchNoteById');
    }
    return mockedFullNoteJson;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante fetchNotes');
    }
    switch (targetDiary) {
      case DiaryType.realDiary:
        return mockedNotesJson;
      case DiaryType.fakeDiary:
        return mockedFullNotesJson;
    }
  }

  @override
  Future<void> saveNote(Map<String, dynamic> json) async {
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante saveNote');
    }
  }
}
