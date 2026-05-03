import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'dart:io';

class MockNoteElement extends Mock implements NoteElement {}

class TestNoteElement extends NoteElement {
  final String _type;
  TestNoteElement(super.content, this._type);
  void setFile(File file) {
    // Implementazione fittizia per i test
  }

  @override
  String get type => _type;

  @override
  File? get file => null; // Implementazione fittizia per i test
}
