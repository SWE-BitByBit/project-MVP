import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class NoteService {
  Future<List<Map<String, dynamic>>> fetchNotes(DiaryType targetDiary) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  Future<Map<String, dynamic>> fetchNoteById(
    DiaryType targetDiary,
    String noteId,
  ) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      "id": "placeholder",
      "title": "Placeholder note",
      "creationDate": DateTime.fromMillisecondsSinceEpoch(1770000000000),
      "lastModified": DateTime.fromMillisecondsSinceEpoch(1770000000000),
    };
  }

  Future<void> saveNote(
    DiaryType targetDiary,
    Map<String, dynamic> json,
  ) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> deleteNote(DiaryType targetDiary, String noteId) async {
    //PLACEHOLDER
    //TODO: implementare chiamata reale
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
