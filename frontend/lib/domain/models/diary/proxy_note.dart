import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';

/// Classe che implementa il pattern Virtual Proxy. Permette la visualizzazione delle informazioni base delle [Note], id, titolo,
/// date di creazione e di ultima modifica, e rimandare ad un secondo momento il caricamento dei NoteElement.
class ProxyNote implements Note {
  /// Campi della nota. id, creationDate e origin sono final dato che una volta impostati l'utente non deve poterli modificare.
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;

  ///Nota reale
  LocalNote? _realNote;

  ProxyNote(this._id, this._title, this._creationDate, this._lastModified);

  /// Getter

  /// Ritorna la stringa identificativa della nota
  @override
  String getId() {
    return _id;
  }

  //Ritorna il titolo della nota
  @override
  String getTitle() {
    return _title;
  }

  /// Ritorna la data di creazione in formato DateTime
  @override
  DateTime getCreationDate() {
    return _creationDate;
  }

  /// Ritorna la data di ultima modifica in formato DateTime
  @override
  DateTime getUpdateDate() {
    return _lastModified;
  }

  /// Ritorna la lista degli elementi della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  List<NoteElement> getNoteElements() {
    load();
    if (_realNote != null) {
      return _realNote!.getNoteElements();
    }
    return [];
  }

  /// Ritorna il numero di elementi che compongono la nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  int getElementCount() {
    load();
    return _realNote!.getElementCount();
  }

  /// Metodi

  /// Se la variabile _note è nulla, carica la nota completa e gliela assegna -> carica la nota completa solo quando necessario
  @override
  Future<void> load() async {
    if (_realNote == null) {
      /// Se possibile fare refactoring per rimuovere questi costruttori
      NoteService s = NoteService();
      NoteRepository r = NoteRepository(s);
      final loadedNote = await r.getNoteById(_id);
      _realNote = loadedNote as LocalNote;
    }
  }

  /// Se il parametro [title] è diverso dal titolo attuale di ProxyNote, il titolo viene cambiato in [title] e _lastModified viene aggiornato. Altrimenti non fa nulla.
  @override
  void setTitle(String title) {
    if (title != _title) {
      _title = title;
      updateLastModified();
    }
  }

  /// Aggiorna lastModified al momento in cui viene chiamato il metodo.
  @override
  void updateLastModified() {
    _lastModified = DateTime.now();
  }

  //Aggiunge un elemento alla lista degli elementi della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  void addElement(NoteElement element, int pos) {
    load();
    _realNote!.addElement(element, pos);
    updateLastModified();
  }

  /// Rimuove il [NoteElement] passato come parametro dalla nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  void removeElement(NoteElement element) {
    load();
    _realNote!.removeElement(element);
    updateLastModified();
  }

  /// Modifica il contenuto di un elemento testuale [NoteTextElement] della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  void editNoteElement(NoteElement element, String newText) {
    load();
    _realNote!.editNoteElement(element, newText);

    updateLastModified();
  }
}
