import 'note_element.dart';

/// Classe per gli elementi testuali delle note
class NoteTextElement extends NoteElement {
  NoteTextElement(super.content, {super.noteParentId, super.noteElementId});

  @override
  String get type => 'text';

}
