import 'note_element.dart';

/// Interfaccia che definisce i metodi standard per le note
abstract interface class Note {
  String getId();
  String getTitle();
  DateTime getCreationDate();
  DateTime getUpdateDate();
  List<NoteElement> getNoteElements();
  void removeElement(NoteElement element);
  void setTitle(String title);
  void updateLastModified();
  void addElement(NoteElement element, int pos);
  void editNoteElement(NoteElement element, String newText);
  int getElementCount();
  Future<void> load() async {}
}
