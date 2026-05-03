import 'note_element.dart';

/// Classe per gli elementi testuali delle note
class NoteTextElement extends NoteElement {
  NoteTextElement(super.content);

  @override
  String get type => 'text';
}
