import 'note_element.dart';
import 'dart:io';

/// Classe per gli elementi delle note che contengono immagini
class NoteImageElement extends NoteElement {
  final File file;

  NoteImageElement(
    super.content, {
    required this.file,
    super.noteParentId,
    super.noteElementId,
  });

  @override
  String get type => 'image';

  @override
  File? get mediaFile => file;
}
