import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

class DiaryViewmodel with ChangeNotifier {
  LocalNote? _currentNote;
  int? _selectedIndex;
  final List<Note> _savedNotes = [];
  bool _loading = false;
  final NoteRepository _noteRepo = NoteRepository();
  //late AuthRepository authRepo;

  DiaryViewmodel() {
    //Chiamare DiaryAccess se l'utente non ha effettuato l'accesso?
    loadPreviews();
  }

  //Ritorna la lista di note salvate (ProxyNote)
  List<Note> getSavedNotes() {
    return _savedNotes;
  }

  //Ritorna true se si stanno effettuando operazioni di caricamento da memoria
  bool isLoading() {
    return _loading;
  }

  ///Pre: non è selezionata nessuna nota (_currentNote è vuota)
  ///Post: _currentNote contiene una LocalNote
  Future<void> loadNote(DiaryType type, Note note) async {
    _loading = true;
    notifyListeners();
    _currentNote = await _noteRepo.getNoteById(type, note.getId()) as LocalNote;
    _loading = false;
    notifyListeners();
  }

  Note? getCurrentNote() {
    return _currentNote;
  }

  //Se è selezionata una nota in _currentNote, essa viene rimossa e viene annullato l'indice selezionato.
  void unloadNote() {
    if (_currentNote != null) {
      _currentNote = null;
      _selectedIndex = null;
    }
  }

  //Ordina le note in ordine decrescente,
  void sortNotes() {
    _savedNotes.sort((a, b) => a.getUpdateDate().compareTo(b.getUpdateDate()));
  }

  //Elimina la nota presente all'indice [index]
  Future<void> deleteNote(int index) async {
    //Eliminazione nel database
    await _noteRepo.deleteNote(
      DiarySession.getDiaryInstance().getDiaryType(),
      _savedNotes[index],
    );
    //Eliminazione in locale
    _savedNotes.removeAt(index);
    unloadNote();
    notifyListeners();
  }

  //Aggiunge una nota al diario ma non la salva in memoria
  void addNewNote() {
    //Caricamento
    _loading = true;
    notifyListeners();

    //Creazione nota vuota
    String noteId = _generateNoteId(15);
    _savedNotes.add(ProxyNote(noteId, "", DateTime.now(), DateTime.now()));
    //_savedNotes.length - 1 = ultima nota aggiunta
    _selectedIndex = _savedNotes.length - 1;

    //Apri la nuova nota
    loadNote(
      DiarySession.getDiaryInstance().getDiaryType(),
      _savedNotes[_selectedIndex!],
    );
    _loading = false;
    notifyListeners();
  }

  //Salva la nota su server. Da chiamare dopo che sono avvenuto modifiche alla nota.
  Future<void> saveNote(LocalNote note) async {
    _noteRepo.saveNote(DiarySession.getDiaryInstance().getDiaryType(), note);
  }

  //Genera una stringa casuale (non già presente nella lista) da usare come Id per le note
  String _generateNoteId(int length) {
    const String allowedChars =
        "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    String id = '';
    //Verifica se l'id esiste già. Se sì ne genera uno nuovo e verifica nuovamente dall'inizio
    for (int i = 0; i < _savedNotes.length; i++) {
      if (i == 0) {
        id = String.fromCharCodes(
          Iterable.generate(
            length,
            (_) =>
                allowedChars.codeUnitAt(Random().nextInt(allowedChars.length)),
          ),
        );
      }
      //Reset counter se trova un duplicato
      if (id == _savedNotes[i].getId()) {
        i = 0;
      }
    }
    return id;
  }

  ///Popola _savedNotes da database con ProxyNote. Se presenti, le note già in memoria vengono rimosse.
  ///Note ordinate per ultima modifica dalla più recente alla più remota
  Future<void> loadPreviews() async {
    DiaryType targetDiary = DiarySession.getDiaryInstance().getDiaryType();
    _loading = true;
    _savedNotes.clear();
    notifyListeners();
    List<Note> noteList = await _noteRepo.getNotes(targetDiary);
    for (int i = 0; i < noteList.length; i++) {
      _savedNotes.insert(i, noteList[i]);
    }
    sortNotes();
    _loading = false;
    notifyListeners();
  }
}
