import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';

class ProxyNote implements Note {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;
  final DiaryType _origin;

  ///Nota reale
  LocalNote? _realNote;

  ProxyNote(
    this._id,
    this._title,
    this._creationDate,
    this._lastModified,
    this._origin,
  );

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
    load();
    if (_realNote != null) {
      return _realNote!.getNoteElements();
    }
    return [];
  }

  //Se il parametro [title] è diverso dal titolo attuale di ProxyNote, il titolo viene cambiato in [title] e _lastModified viene aggiornato. Altrimenti non fa nulla.
  @override
  void setTitle(String title) {
    if (title != _title) {
      _title = title;
    }
  }

  //Aggiorna lastModified al momento in cui viene chiamato il metodo.
  @override
  void updateLastModified() {
    _lastModified = DateTime.now();
  }

  @override
  void setElementText(int index, String newText) {
    load();
    _realNote!.setElementText(index, newText);
  }

  @override
  int getElementCount() {
    load();
    return _realNote!.getElementCount();
  }

  //Aggiunge un elemento alla lista degli elementi della nota reale. Carica la nota reale prima di eseguire l'operazione.
  @override
  void addElement(String elem, String type, int pos) {
    load();
    _realNote!.addElement(elem, type, pos);
  }

  @override
  ///Se la variabile _note è nulla, carica la nota completa e gliela assegna
  Future<void> load() async {
    if (_realNote == null) {
      NoteService s = NoteService();
      NoteRepository r = NoteRepository(s);
      final loadedNote = await r.getNoteById(_origin, _id);
      _realNote = loadedNote as LocalNote;
    }
    _realNote!.load();
  }
}
