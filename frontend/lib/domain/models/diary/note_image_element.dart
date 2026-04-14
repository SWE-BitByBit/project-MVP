import 'note_element.dart';

class NoteImageElement extends NoteElement {
  NoteImageElement(String imagepath) {
    setContent(imagepath);
  }

  @override
  String getType() {
    return 'image';
  }
}
