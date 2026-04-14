import 'note_element.dart';

class NoteTextElement extends NoteElement {
  NoteTextElement(String text) {
    setContent(text);
  }

  @override
  String getType() {
    return 'text';
  }
}
