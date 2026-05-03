import 'dart:io';

import 'note_element.dart';

/// Classe per gli elementi delle note che contengono tracce audio
class NoteAudioElement extends NoteElement {
  NoteAudioElement(
    super.content,
    this._audioFile, {
    super.noteParentId,
    super.noteElementId,
  });

  File _audioFile;

  @override
  String get type => 'audio';

  @override
  File get file => _audioFile;

  @override
  void setFile(File audioFile) {
    _audioFile = audioFile;
  }
}
