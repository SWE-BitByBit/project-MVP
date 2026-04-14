import 'note_element.dart';

abstract interface class Note {
  //Definizione dei metodi - implementazione nelle classi che implementano questa interfaccia
  String getId();
  String getTitle();
  DateTime getCreationDate();
  DateTime getUpdateDate();
  List<NoteElement> getNoteElements();
  void setTitle(String title);
  void updateLastModified();
  void addElement(String elem, String type, int pos);
}
