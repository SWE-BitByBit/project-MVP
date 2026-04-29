import 'note_element.dart';

/// Interfaccia che definisce i metodi e le proprietà standard per le note.
abstract interface class Note {
  // Proprietà (getter espliciti per definire i contratti di sola lettura)
  String get id;
  String get title;
  DateTime get creationDate;
  DateTime get updateDate;
  List<NoteElement> get noteElements;

  // Setter per il titolo (permetterà di modificare il titolo)
  set title(String newTitle);

  // Metodi operativi
  void updateLastModified();
  void addElement(NoteElement element, int pos);
  void removeElement(NoteElement element);
  void editNoteElement(NoteElement element, String newText);
  int getElementCount();

}