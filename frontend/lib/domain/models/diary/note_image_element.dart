import 'note_element.dart';

/// Classe per gli elementi delle note che contengono immagini
class NoteImageElement extends NoteElement {

  NoteImageElement(
    super.content,
      {required super.file,
    super.noteParentId,
    super.noteElementId,
  });

  @override
  String get type => 'image';

}
