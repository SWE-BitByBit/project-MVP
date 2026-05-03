import 'dart:io';

import 'note_element.dart';

/// Classe per gli elementi delle note che contengono immagini
class NoteImageElement extends NoteElement {
  File _imageFile;

  NoteImageElement(
    super.content,
    this._imageFile, {
    super.noteParentId,
    super.noteElementId,
  });

  @override
  String get type => 'image';

  @override
  File get file => _imageFile;

  @override
  void setFile(File imageFile) {
    _imageFile = imageFile;
  }
}
