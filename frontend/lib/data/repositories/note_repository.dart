import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/note_dto.dart';

///Classe che fa da intermediario tra Service e ViewModel
///
///Si occupa del recupero dei dati grezzi tramite Service e della loro conversione in oggetti di dominio [Note] prima di passarli al ViewModel.
///Inoltre gestisce anche le richieste del ViewModel relative al salvataggio e all'eliminazione delle note, convertendo gli oggetti [Note] passati dal ViewModel
///nei formati richiesti dal Service.
class NoteRepository {
  final NoteService _noteService = NoteService();
  final NoteDTO _noteDTO = NoteDTO();
  NoteRepository();

  ///Recupera le note di un diario senza le informazioni sui loro elementi
  ///
  ///Ottiene la lista di note in formato JSON dal service, poi la converte in lista di [Note] tramite [NoteDTO]
  Future<List<Note>> getNotes(DiaryType targetDiary) async {
    List<Map<String, dynamic>> rawNotes = await _noteService.fetchNotes(
      targetDiary,
    );
    List<Note> noteOut = [];
    for (int i = 0; i < rawNotes.length; i++) {
      noteOut.add(_noteDTO.fromJson(rawNotes[i], targetDiary));
    }
    return noteOut;
  }

  ///Ritorna una nota completa recuperata dal service in base al [noteId] fornito
  ///
  ///Il service fornisce la nota in formato JSON, che quindi viene convertita in Note tramite [NoteDTO]
  Future<Note> getNoteById(DiaryType targetDiary, String noteId) async {
    Map<String, dynamic> json = await _noteService.fetchNoteById(
      targetDiary,
      noteId,
    );
    return _noteDTO.fromJson(json, targetDiary);
  }

  ///Crea una nuova nota nel backend
  ///
  ///Converte [note] in JSON tramite [NoteDTO], e poi lo invia al service
  Future<void> saveNote(DiaryType targetDiary, Note note) async {
    Map<String, dynamic> json = _noteDTO.toJson(note);
    await _noteService.saveNote(targetDiary, json);
  }

  ///Elimina una nota dal backend
  ///
  ///Recupera l'[id] della nota e lo invia al service per completare l'eliminazione
  Future<void> deleteNote(DiaryType targetDiary, Note note) async {
    await _noteService.deleteNote(targetDiary, note.getId());
  }
}
