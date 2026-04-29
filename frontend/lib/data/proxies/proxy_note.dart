import '../repositories/note_repository.dart';
import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/local_note.dart';
import '../../domain/models/diary/note_element.dart';

/// Implementazione Proxy dell'interfaccia [Note].
/// Conserva in memoria solo i metadati (anteprima). Scarica gli elementi
/// pesanti (NoteElement) dal server solo quando viene esplicitamente richiesto tramite [load].
class ProxyNote implements Note {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;

  LocalNote? _realNote;

  final NoteRepository _repository;

  ProxyNote({
    required String id,
    required String title,
    required DateTime creationDate,
    required DateTime lastModified,
    required NoteRepository repository,
  })  : _id = id,
        _title = title,
        _creationDate = creationDate,
        _lastModified = lastModified,
        _repository = repository;

  @override
  String get id => _id;

  // Se l'oggetto reale esiste, deleghiamo a lui. Altrimenti usiamo la cache locale.
  @override
  String get title => _realNote?.title ?? _title;

  @override
  set title(String newTitle) {
    _title = newTitle;
    _realNote?.title = newTitle; // Propaga la modifica alla nota reale se presente
    updateLastModified();
  }

  @override
  DateTime get creationDate => _creationDate;

  @override
  DateTime get updateDate => _realNote?.updateDate ?? _lastModified;

  @override
  List<NoteElement> get noteElements {
    // Se la nota non è ancora stata caricata, restituiamo vuoto.
    // L'UI sa che deve chiamare load() prima di accedere al contenuto.
    return _realNote?.noteElements ?? [];
  }

  @override
  int getElementCount() => _realNote?.getElementCount() ?? 0;

  @override
  void updateLastModified() {
    _lastModified = DateTime.now();
    _realNote?.updateLastModified();
  }

  @override
  void addElement(NoteElement element, int pos) {
    _realNote?.addElement(element, pos);
    updateLastModified();
  }

  @override
  void removeElement(NoteElement element) {
    _realNote?.removeElement(element);
    updateLastModified();
  }

  @override
  void editNoteElement(NoteElement element, String newText) {
    _realNote?.editNoteElement(element, newText);
    updateLastModified();
  }

  /// Scarica l'intero contenuto della nota tramite il repository solo se non è già presente in memoria.
  Future<void> load() async {
    if (_realNote == null) {
      _realNote = await _repository.getNoteById(_id) as LocalNote;

      _title = _realNote!.title;
      _lastModified = _realNote!.updateDate;
    }
  }
}