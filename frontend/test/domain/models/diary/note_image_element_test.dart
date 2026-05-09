import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Sostituisci con il path corretto al tuo file NoteImageElement
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';

class MockFile extends Mock implements File {}

void main() {
  group('NoteImageElement - Tests', () {
    late MockFile mockFile;
    const String testContent = 'Descrizione o didascalia immagine';
    const String testParentId = 'note_789';
    const String testElementId = 'element_012';

    setUp(() {
      mockFile = MockFile();
    });

    test('should initialize correctly with all provided parameters', () {
      // Arrange
      // (Setup gestito nel blocco setUp)

      // Act
      final element = NoteImageElement(
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

    test('should return exactly "image" as type', () {
      // Arrange
      final element = NoteImageElement(
        testContent,
        file: mockFile,
      );

      // Act
      final type = element.type;

      // Assert
      expect(type, 'image');
    });

    test('should return the correct File instance from mediaFile getter', () {
      // Arrange
      final element = NoteImageElement(
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