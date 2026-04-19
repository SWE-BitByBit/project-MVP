import 'note_element.dart';

///Classe per gli elementi testuali delle note
class NoteTextElement extends NoteElement {
  NoteTextElement(String text) {
    setContent(text);
  }

  @override
  String getType() {
    return 'text';
  }
}
