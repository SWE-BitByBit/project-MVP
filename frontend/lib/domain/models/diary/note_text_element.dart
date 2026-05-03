import 'dart:io';

import 'note_element.dart';

/// Classe per gli elementi testuali delle note
class NoteTextElement extends NoteElement {
  NoteTextElement(super.content, {super.noteParentId, super.noteElementId});

  @override
  String get type => 'text';

  @override
  void setFile(File file) {}

  @override
  File? get file => null;
}
