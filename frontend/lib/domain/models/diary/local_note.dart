import 'note.dart';
import 'note_element.dart';

/// Implementazione concreta dell'interfaccia [Note].
/// Rappresenta una nota completamente caricata in memoria [cite: 74-79].
class LocalNote implements Note {

  /// Identificativo univoco della nota. `final` garantisce che non sia modificabile.
  @override
  final String id;

  /// Data di creazione. `final` garantisce che non sia modificabile.
  @override
  final DateTime creationDate;

  String _title;
  DateTime _lastModified;

  final List<NoteElement> _noteContents;

  /// Costruttore
  LocalNote({
    required this.id,
    required String title,
    required this.creationDate,
    required DateTime lastModified,
    List<NoteElement>? initialElements,
  })  : _title = title,
        _lastModified = lastModified,
        _noteContents = initialElements ?? <NoteElement>[];

  @override
  String get title => _title;

  @override
  DateTime get updateDate => _lastModified;

  @override
  List<NoteElement> get noteElements => List.unmodifiable(_noteContents);


  /// Aggiorna il titolo e, se è cambiato, aggiorna automaticamente la data di modifica.
  @override
  set title(String newTitle) {
    if (_title != newTitle) {
      _title = newTitle;
      updateLastModified();
    }
  }

  // --- METODI ---

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
      updateLastModified(); // Aggiunto per coerenza: modificare il contenuto modifica la nota
    }
  }

  /// Rimuove il [NoteElement] dalla lista degli elementi.
  @override
  void removeElement(NoteElement element) {
    if (_noteContents.remove(element)) {
      updateLastModified();
    }
  }

  /// Modifica il testo di un elemento specifico.
  @override
  void editNoteElement(NoteElement element, String newText) {
    final index = _noteContents.indexOf(element);
    if (index != -1) {
      _noteContents[index].content = newText;
      updateLastModified();
    }
  }

}