import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

class DiaryViewmodel with ChangeNotifier {
  Note? _currentNote;
  final List<Note> _savedNotes = [];
  bool _loading = false;

  final NoteRepository _noteRepo;
  //late AuthRepository authRepo;
  DiaryViewmodel(this._noteRepo);

  //Ritorna la lista di note salvate (ProxyNote)
  List<Note> getSavedNotes() {
    return _savedNotes;
  }

  //Semplice metodo
  int getNoteListSize() {
    return _savedNotes.length;
  }

  //Ritorna true se si stanno effettuando operazioni di caricamento da memoria
  bool isLoading() {
    return _loading;
  }

  ///Pre: non è selezionata nessuna nota (_currentNote è vuota)
  ///Post: _currentNote contiene una LocalNote
  void loadNote(int index) {
    _currentNote = _savedNotes[index];
    if (_currentNote != null) {
      _currentNote!.load();
    }
  }

  Note? getCurrentNote() {
    return _currentNote;
  }

  //Se è selezionata una nota in _currentNote, essa viene rimossa e viene annullato l'indice selezionato.
  void unloadNote() {
    if (_currentNote != null) {
      _currentNote = null;
    }
  }

  //Ordina le note in ordine decrescente,
  void sortNotes() {
    _savedNotes.sort((a, b) => a.getUpdateDate().compareTo(b.getUpdateDate()));
  }

  //Elimina la nota presente all'indice [index]
  Future<void> deleteNote(int index, DiaryType diary) async {
    //Eliminazione nel database
    await _noteRepo.deleteNote(diary, _savedNotes[index]);
    //Eliminazione in locale
    _savedNotes.removeAt(index);
    unloadNote();
    notifyListeners();
  }

  //Aggiunge una nuova [ProxyNote] al diario e la salva in memoria
  void addNewNote(DiaryType diary) {
    //Caricamento
    _loading = true;
    notifyListeners();

    //Creazione nota vuota
    String noteId = _generateNoteId(15);
    Note newNote = ProxyNote(noteId, "", DateTime.now(), DateTime.now(), diary);
    //Salvataggio nota
    _savedNotes.add(newNote);
    _noteRepo.saveNote(diary, newNote);
    _loading = false;
    notifyListeners();
  }

  //Aggiunge un nuovo elemento alla [Note] passata, in posizione [pos]
  void addNoteElement(Note note, String elem, int pos) {
    note.addElement(elem, "text", pos);
    note.updateLastModified();
    notifyListeners();
  }

  //Aggiunge un elemento media (immagine/traccia audio) alla [Note] passata, in posizione [pos]
  void addNoteMediaElement(Note note, File file, String type, int pos) {
    note.addElement(file.path, type, pos);
    note.updateLastModified();
    notifyListeners();
  }

  //Salva la nota su server. Da chiamare dopo che sono avvenute modifiche alla nota.
  Future<void> saveNote(Note note, DiaryType diary) async {
    _noteRepo.saveNote(diary, note);
    notifyListeners();
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
  Future<void> loadPreviews(DiaryType diary) async {
    _loading = true;
    _savedNotes.clear();
    notifyListeners();
    List<Note> noteList = await _noteRepo.getNotes(diary);
    for (int i = 0; i < noteList.length; i++) {
      _savedNotes.insert(i, noteList[i]);
    }
    sortNotes();
    _loading = false;
    notifyListeners();
  }
}
