import 'note_element.dart';

/// Interfaccia che definisce i metodi e le proprietà standard per le note.
abstract interface class Note {
  String get id;
  String get title;
  DateTime get creationDate;
  DateTime get updateDate;
  List<NoteElement> get noteElements;

  // Setter per il titolo della nota.
  set title(String newTitle);

  void updateLastModified();
  void addElement(NoteElement element, int pos);
  void removeElement(NoteElement element);
  void editNoteElement(NoteElement element, String newText);
  int getElementCount();
}
