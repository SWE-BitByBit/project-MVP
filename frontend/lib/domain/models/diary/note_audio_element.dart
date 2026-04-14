import 'note_element.dart';

class NoteAudioElement extends NoteElement {
  NoteAudioElement(String audiopath) {
    setContent(audiopath);
  }

  @override
  String getType() {
    return 'audio';
  }
}
