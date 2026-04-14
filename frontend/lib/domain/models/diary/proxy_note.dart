import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';

class ProxyNote implements Note {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;
  LocalNote? _note;

  ProxyNote(this._id, this._title, this._creationDate, this._lastModified);

  //Ritorna il titolo della nota
  @override
  String getTitle() {
    return _title;
  }

  //Ritorna la stringa identificativa della nota
  @override
  String getId() {
    return _id;
  }

  //Ritorna la data di creazione in formato DateTime
  @override
  DateTime getCreationDate() {
    return _creationDate;
  }

  //Ritorna la data di ultima modifica in formato DateTime
  @override
  DateTime getUpdateDate() {
    return _lastModified;
  }

  //Ritorna la lista degli elementi della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  List<NoteElement> getNoteElements() {
    _load();
    return _note!.getNoteElements();
  }

  //Se il parametro [title] è diverso dal titolo attuale di ProxyNote, il titolo viene cambiato in [title] e _lastModified viene aggiornato. Altrimenti non fa nulla.
  @override
  void setTitle(String title) {
    if (title != _title) {
      _title = title;
      updateLastModified();
    }
  }

  //Aggiorna lastModified al momento in cui viene chiamato il metodo.
  @override
  void updateLastModified() {
    _lastModified = DateTime.now();
  }

  //Aggiunge un elemento alla lista degli elementi della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  void addElement(String elem, String type, int pos) {
    _load();
    _note!.addElement(elem, type, pos);
  }

  ///Se la variabile _note è nulla, carica la nota completa e gliela assegna
  Future<void> _load() async {
    if (_note == null) {
      NoteRepository noteRepo = NoteRepository();
      final loadedNote = await noteRepo.getNoteById(
        DiarySession.getDiaryInstance().getDiaryType(),
        _id,
      );
      _note = loadedNote as LocalNote;
    }
  }
}
