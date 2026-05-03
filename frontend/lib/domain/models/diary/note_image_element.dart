import 'dart:io';

import 'note_element.dart';

/// Classe per gli elementi delle note che contengono immagini
class NoteImageElement extends NoteElement {
  NoteImageElement(super.content);
  File? _imageFile;

  @override
  String get type => 'image';

  @override
  File? get file => _imageFile;

  @override
  void setFile(File imageFile) {
    _imageFile = imageFile;
  }
}
