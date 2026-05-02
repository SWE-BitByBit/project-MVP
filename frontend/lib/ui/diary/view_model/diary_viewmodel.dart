import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/proxy_note.dart';

/// Classe che gestisce logica di presentazione e stato dell'interfaccia per la funzionalità dei
/// diari. Fa uso del mixin [ChangeNotifier] per notificare i widget in ascolto quando avvengono
/// cambiamenti di stato.
class DiaryViewmodel with ChangeNotifier {
  final NoteRepository _noteRepo;
  final DiaryAccountRepository _accRepo;

  ///Stato UI
  Note? _currentNote;
  final List<Note> _savedNotes = [];
  bool _loading = false;
  String? _error;

  /// Stato impostazione password diario fittizio
  String _passwordError = "";
  bool _fakePwdSet = false;
  bool? _passwordMatch;

  ///Crea istanza di [DiaryViewmodel] con il [NoteRepository] specificato
  DiaryViewmodel(this._noteRepo, this._accRepo);

  ///Getters

  /// Ritorna l'ultimo errore, altrimenti ritorna null |
  String? get error => _error;

  /// Ritorna stringa errore password
  String get passwordError => _passwordError;

  /// Ritorna se la password del diario fittizio è stata impostata con successo
  bool get fakePwdSet => _fakePwdSet;

  /// Ritorna se le password fornite combaciano
  bool? get passwordMatch => _passwordMatch;

  //Ritorna la lista di note presenti nel diario |
  List<Note> getSavedNotes() {
    return _savedNotes;
  }

  //Ritorna il numero di note attualmente presenti nel diario |
  int getNoteListSize() {
    return _savedNotes.length;
  }

  //Ritorna la nota attualmente selezionata, se presente |
  Note? getCurrentNote() {
    return _currentNote;
  }

  //Ritorna true se si stanno effettuando operazioni di caricamento da memoria |
  bool isLoading() {
    return _loading;
  }

  ///Metodi gestione note

  //Ordina le note in ordine decrescente, |
  void sortNotes() {
    _loading = true;

    _savedNotes.sort((a, b) => b.getUpdateDate().compareTo(a.getUpdateDate()));

    _loading = false;
    //notifyListeners();
  }

  //Aggiunge una nuova [ProxyNote] al diario e la salva in memoria |
  void addNewNote(DiaryType diary) {
    try {
      //Caricamento
      _loading = true;
      notifyListeners();

      //Creazione nota vuota
      String noteId = _generateNoteId(15);
      Note newNote = ProxyNote(noteId, "", DateTime.now(), DateTime.now());
      //Salvataggio nota
      _savedNotes.add(newNote);
      _noteRepo.saveNote(diary, newNote);
      _loading = false;
      notifyListeners();
    } catch (e) {
      "Errore nella creazione della nota: $e";
    }
  }

  //Aggiorna il titolo della nota selezionata |
  void updateNoteTitle(String title) {
    try {
      _currentNote!.setTitle(title);
      notifyListeners();
    } catch (e) {
      "Errore nell'aggiornamento del titolo della nota: $e";
    }
  }

  //Aggiunge un nuovo elemento alla [Note] passata, nella posizione passata come parametro |
  void addNoteElement(Note note, String text, int pos) {
    try {
      NoteElement elem = NoteTextElement(text);
      note.addElement(elem, pos);
      note.updateLastModified();
      notifyListeners();
    } catch (e) {
      "Errore nell'aggiunta dell'elemento: $e";
    }
  }

  //Aggiunge un elemento media (immagine/traccia audio) alla [Note] passata, in posizione [pos] |
  void addNoteMediaElement(Note note, File file, String type, int pos) {
    try {
      NoteElement elem;
      switch (type) {
        case "image":
          elem = NoteImageElement(file.path);
          break;
        case "audio":
          elem = NoteAudioElement(file.path);
          break;
        default:
          throw _error = "tipo elemento non riconosciuto";
      }
      note.addElement(elem, pos);
      note.updateLastModified();
      notifyListeners();
    } catch (e) {
      "Errore nell'aggiunta dell'elemento: $e";
    }
  }

  //Rimuove il [NoteElement] passato dalla [Note] passata
  void removeNoteElement(Note note, NoteElement element) {
    try {
      note.removeElement(element);
      notifyListeners();
    } catch (e) {
      "Errore nella rimozione dell'elemento: $e";
    }
  }

  /// Aggiorna il contenuto di un [NoteTextElement] appartenente alla [Note] passata |
  void updateNoteTextElement(Note note, NoteElement element, String text) {
    try {
      note.editNoteElement(element, text);
      notifyListeners();
    } catch (e) {
      "Errore nell'aggiornamento dell'elemento testuale della nota: $e";
    }
  }

  //Salva la nota su server. Da chiamare dopo che sono avvenute modifiche alla nota. |
  Future<void> saveNote(Note note, DiaryType diary) async {
    try {
      await _noteRepo.saveNote(diary, note);
    } catch (e) {
      "Errore nel salvataggio della nota: $e";
    } finally {
      notifyListeners();
    }
  }

  //Elimina la nota presente all'indice [index]
  Future<void> deleteNote(String noteId, DiaryType diary) async {
    try {
      //Eliminazione nel database
      await _noteRepo.deleteNote(
        _savedNotes.where((note) => note.getId() == noteId).first,
      );
      //Eliminazione in locale
      _savedNotes.removeWhere((note) => note.getId() == noteId);
      unloadNote();
    } catch (e) {
      _error = "Errore nell'eliminazione della nota: $e";
    } finally {
      notifyListeners();
    }
  }

  //PLACEHOLDER Genera una stringa casuale (non già presente nella lista) da usare come Id per l'inserimento di una nuova nota |
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

  ///Popola _savedNotes da database con ProxyNote. Se presenti, le note già in memoria vengono rimosse. |
  Future<void> loadPreviews(DiaryType diary) async {
    _loading = true;
    try {
      _savedNotes.clear();
      notifyListeners();
      List<Note> noteList = await _noteRepo.getNotes(diary);
      for (int i = 0; i < noteList.length; i++) {
        _savedNotes.insert(i, noteList[i]);
      }
      _error = null;
    } catch (e) {
      _error = 'Errore nel caricamento delle note: $e';
    } finally {
      sortNotes();
      _loading = false;
      notifyListeners();
    }
  }

  ///Pre: non è selezionata nessuna nota (_currentNote è vuota)
  ///Post: _currentNote contiene una LocalNote |
  void loadNote(int index) {
    try {
      _currentNote = _savedNotes[index];
      if (_currentNote != null) {
        _currentNote!.load();
      }
    } catch (e) {
      _error = 'Errore nel caricamento della nota selezionata: $e';
    }
  }

  //Se è selezionata una nota in _currentNote, essa viene rimossa e viene annullato l'indice selezionato.
  void unloadNote() {
    if (_currentNote != null) {
      _currentNote = null;
    }
  }

  /// Impostazione password diario fittizio

  /// Metodo che resetta lo stato quando viene aperto il widget per l'impostazione password diario
  void resetFakePasswordState() {
    _passwordError = '';
    _fakePwdSet = false;
    _passwordMatch = null;
    notifyListeners();
  }

  /// Metodo validazione password mentre viene scritta - errori vengono inseriti in _passwordError
  void validateDiaryPassword(String pwd) {
    /// Clear errore precedente
    _passwordError = '';

    if (pwd.length < 10) {
      _passwordError += "La password deve essere lunga almeno 10 caratteri.\n";
    }

    if (!pwd.contains(RegExp(r"[A-Z]")) || !pwd.contains(RegExp(r"[a-z]"))) {
      _passwordError +=
          "La password deve contenere lettere maiuscole e minuscole.\n";
    }
    if (!pwd.contains(RegExp(r"[0-9]"))) {
      _passwordError += "La password deve contenere almeno un numero.\n";
    }
    if (!pwd.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _passwordError +=
          "La password deve contenere almeno un carattere speciale.\n";
    }

    if (pwd.contains(RegExp(r"[\s]"))) {
      _passwordError += "La password non può contenere spazi.\n";
    }

    notifyListeners();
  }

  /// Verifica se le password combaciano
  void checkPwdMatch(String pwd1, String pwd2) {
    _passwordMatch = (pwd1 == pwd2);
    notifyListeners();
  }

  /// Metodo per l'invio della nuova password
  Future<void> submitDiaryPassword(String realPwd, String pwd) async {
    try {
      if (realPwd.isEmpty) {
        _passwordError += "Inserire password del diario reale.\n";
      } else {
        DiaryAccessResult res = await _accRepo.clarifyAccessResult(realPwd);
        if (res != DiaryAccessResult.realDiary) {
          _passwordError += "Password diario reale inserita errata.\n";
        } else {
          _passwordError += await _accRepo.registerFakeDiaryPassword(pwd);

          if (_passwordError.isEmpty) {
            _fakePwdSet = true;
          }
        }
      }

      notifyListeners();
    } catch (e) {
      _error = "Errore nell'invio della password: $e";
      notifyListeners();
    }
  }
}
