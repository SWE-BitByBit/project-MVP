import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

/// Classe che gestisce logica di presentazione e stato dell'interfaccia per la funzionalità dei
/// diari. Fa uso del mixin [ChangeNotifier] per notificare i widget in ascolto quando avvengono
/// cambiamenti di stato.
class DiaryViewmodel with ChangeNotifier {
  final NoteRepository _noteRepo;
  //late AuthRepository authRepo;

  ///Stato UI
  Note? _currentNote;
  final List<Note> _savedNotes = [];
  bool _loading = false;

  ///Crea istanza di [DiaryViewmodel] con il [NoteRepository] specificato
  DiaryViewmodel(this._noteRepo);

  ///Getters

  //Ritorna la lista di note presenti nel diario
  List<Note> getSavedNotes() {
    return _savedNotes;
  }

  //Ritorna il numero di note attualmente presenti nel diario
  int getNoteListSize() {
    return _savedNotes.length;
  }

  //Ritorna la nota attualmente selezionata, se presente
  Note? getCurrentNote() {
    return _currentNote;
  }

  //Ritorna true se si stanno effettuando operazioni di caricamento da memoria
  bool isLoading() {
    return _loading;
  }

  ///Metodi gestione note

  //Ordina le note in ordine decrescente,
  void sortNotes() {
    _savedNotes.sort((a, b) => a.getUpdateDate().compareTo(b.getUpdateDate()));
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

  //Aggiorna il titolo della nota selezionata
  void updateNoteTitle(String title) {
    _currentNote!.setTitle(title);
    notifyListeners();
  }

  //Aggiunge un nuovo elemento alla [Note] passata, nella posizione passata come parametro
  void addNoteElement(Note note, String text, int pos) {
    note.addElement(text, "text", pos);
    note.updateLastModified();
    notifyListeners();
  }

  //Aggiunge un elemento media (immagine/traccia audio) alla [Note] passata, in posizione [pos]
  void addNoteMediaElement(Note note, File file, String type, int pos) {
    note.addElement(file.path, type, pos);
    note.updateLastModified();
    notifyListeners();
  }

  //Rimuove il [NoteElement] passato dalla [Note] passata
  void removeNoteElement(Note note, NoteElement element) {
    note.removeElement(element);
    notifyListeners();
  }

  //Salva la nota su server. Da chiamare dopo che sono avvenute modifiche alla nota.
  Future<void> saveNote(Note note, DiaryType diary) async {
    _noteRepo.saveNote(diary, note);
    notifyListeners();
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

  //Genera una stringa casuale (non già presente nella lista) da usare come Id per l'inserimento di una nuova nota
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

  ///Metodi caricamento dati

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

  ///Pre: non è selezionata nessuna nota (_currentNote è vuota)
  ///Post: _currentNote contiene una LocalNote
  void loadNote(int index) {
    _currentNote = _savedNotes[index];
    if (_currentNote != null) {
      _currentNote!.load();
    }
  }

  //Se è selezionata una nota in _currentNote, essa viene rimossa e viene annullato l'indice selezionato.
  void unloadNote() {
    if (_currentNote != null) {
      _currentNote = null;
    }
  }
}
