import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/note_dto.dart';

class NoteRepository {
  Future<List<Note>> getNotes(DiaryType targetDiary) async {
    List<Note> notes = [];
    return notes;
  }

  Future<Note> getNoteById(DiaryType targetDiary, String noteId) async {
    NoteDTO dto = NoteDTO();
    Map<String, dynamic> json = await NoteService().fetchNoteById(
      targetDiary,
      noteId,
    );
    Note note = dto.fromJson(json);
    return note;
  }

  Future<void> saveNote(DiaryType targetDiary, Note note) async {
    NoteDTO dto = NoteDTO();
    Map<String, dynamic> json = dto.toJson(note);
    await NoteService().saveNote(targetDiary, json);
  }

  Future<void> deleteNote(DiaryType targetDiary, Note note) async {
    await NoteService().deleteNote(targetDiary, note.getId());
  }
}
