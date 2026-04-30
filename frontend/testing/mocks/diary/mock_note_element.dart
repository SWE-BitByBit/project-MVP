import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';

class MockNoteElement extends Mock implements NoteElement {}

class TestNoteElement extends NoteElement {
  final String _type;
  TestNoteElement(String content, this._type) : super(content);

  @override
  String get type => _type;
}