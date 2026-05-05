import 'note.dart';
import 'note_element.dart';

/// Implementazione concreta dell'interfaccia [Note].
class LocalNote implements Note {
  /// Identificativo univoco della nota.
  @override
  final String id;

  /// Data di creazione.
  @override
  final DateTime creationDate;

  String _title;
  DateTime _lastModified;

  final List<NoteElement> _noteContents;

  LocalNote({
    required this.id,
    required String title,
    required this.creationDate,
    required DateTime lastModified,
    List<NoteElement>? initialElements,
  }) : _title = title,
       _lastModified = lastModified,
       _noteContents = initialElements ?? <NoteElement>[];

  @override
  String get title => _title;

  @override
  DateTime get updateDate => _lastModified;

  @override
  List<NoteElement> get noteElements => _noteContents;

  /// Aggiorna il titolo e, se è cambiato, aggiorna automaticamente la data di modifica.
  @override
  set title(String newTitle) {
    if (_title != newTitle) {
      _title = newTitle;
      updateLastModified();
    }
  }

  /// Aggiorna la data di ultima modifica al momento attuale.
  @override
  void updateLastModified() {
    _lastModified = DateTime.now();
  }

  /// Ritorna il numero di elementi presenti nella nota.
  @override
  int getElementCount() => _noteContents.length;

  /// Aggiunge un [NoteElement] nella posizione specificata [pos].
  @override
  void addElement(NoteElement element, int pos) {
    if (pos >= 0 && pos <= _noteContents.length) {
      _noteContents.insert(pos, element);
      updateLastModified();
    }
  }

  /// Rimuove il [NoteElement] specificato dalla nota.
  @override
  void removeElement(NoteElement element) {
    if (_noteContents.remove(element)) {
      updateLastModified();
    }
  }

  @override
  void editNoteElement(NoteElement element, String newText) {
    final index = _noteContents.indexOf(element);
    if (index != -1) {
      _noteContents[index].content = newText;
      updateLastModified();
    }
  }
}
