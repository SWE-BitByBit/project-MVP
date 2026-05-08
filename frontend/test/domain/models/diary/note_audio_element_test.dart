import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Sostituisci con il path corretto al tuo file NoteAudioElement
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';

class MockFile extends Mock implements File {}

void main() {
  group('NoteAudioElement -', () {
    late MockFile mockFile;
    const String testContent = 'Audio transcript or description';
    const String testParentId = 'note_123';
    const String testElementId = 'element_456';

    setUp(() {
      mockFile = MockFile();
    });

    test('should initialize correctly with all provided parameters', () {
      // Arrange
      // (Il setup è gestito sopra)

      // Act
      final element = NoteAudioElement(
        testContent,
        file: mockFile,
        noteParentId: testParentId,
        noteElementId: testElementId,
      );

      // Assert
      expect(element.content, testContent);
      expect(element.file, mockFile);
      expect(element.noteParentId, testParentId);
      expect(element.noteElementId, testElementId);
    });

    test('should return exactly "audio" as type', () {
      // Arrange
      final element = NoteAudioElement(
        testContent,
        file: mockFile,
      );

      // Act
      final type = element.type;

      // Assert
      expect(type, 'audio');
    });

    test('should return the correct File instance from mediaFile getter', () {
      // Arrange
      final element = NoteAudioElement(
        testContent,
        file: mockFile,
      );

      // Act
      final mediaFile = element.mediaFile;

      // Assert
      expect(mediaFile, isA<File>());
      expect(mediaFile, mockFile);
    });
  });
}