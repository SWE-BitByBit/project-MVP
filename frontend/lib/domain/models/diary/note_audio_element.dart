import 'note_element.dart';
import 'dart:io';

/// Classe per gli elementi delle note che contengono tracce audio
class NoteAudioElement extends NoteElement {
  final File file;

  NoteAudioElement(
    super.content, {
    required this.file,
    super.noteParentId,
    super.noteElementId,
  });

  @override
  String get type => 'audio';

  /// getter per la ui da usare nelle classi della ui.
  @override
  File? get mediaFile => file;
}
