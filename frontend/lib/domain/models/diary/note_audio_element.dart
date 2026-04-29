import 'note_element.dart';

///Classe per gli elementi delle note che contengono tracce audio
class NoteAudioElement extends NoteElement {
  NoteAudioElement(super.content);

  @override
  String get type => 'audio';
}
