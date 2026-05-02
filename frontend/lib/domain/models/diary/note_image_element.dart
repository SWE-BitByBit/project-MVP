import 'note_element.dart';

///Classe per gli elementi delle note che contengono immagini
class NoteImageElement extends NoteElement {
  NoteImageElement(String imagepath) {
    setContent(imagepath);
  }

  @override
  String getType() {
    return 'image';
  }
}
