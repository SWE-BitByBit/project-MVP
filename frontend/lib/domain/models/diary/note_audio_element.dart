import 'note_element.dart';

/// Classe per gli elementi delle note che contengono tracce audio
class NoteAudioElement extends NoteElement {
  NoteAudioElement(
    super.content,
     {required super.file,
    super.noteParentId,
    super.noteElementId,
  });

  @override
  String get type => 'audio';


}
