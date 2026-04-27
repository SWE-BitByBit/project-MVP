import 'note_element.dart';

///Classe per gli elementi delle note che contengono tracce audio
class NoteAudioElement extends NoteElement {
  NoteAudioElement(String audiopath) {
    setContent(audiopath);
  }

  @override
  String getType() {
    return 'audio';
  }
}
