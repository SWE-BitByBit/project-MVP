import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/note_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/diary/$name'
        : 'testing/fixtures/diary/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('NoteDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente un JSON valido (Happy Path)', () {
        // Arrange
        final json = readFixture('note_valid.json');

        // Act
        final result = NoteDTO.fromJson(json);

        // Assert
        expect(result, isA<LocalNote>());
        expect(result.id, 'note_123');
        expect(result.title, 'Il mio diario');
        expect(result.creationDate, DateTime.parse('2023-10-15T10:00:00.000Z'));
        // Gestione del getter "updateDate" o "lastModified" implementato in LocalNote
        // Il costruttore prende lastModified, l'interfaccia si aspetta updateDate.
        expect(result.updateDate, DateTime.parse('2023-10-15T14:30:00.000Z'));

        final elements = result.noteElements;
        expect(elements.length, 4);

        expect(elements[0], isA<NoteTextElement>());
        expect(elements[0].content, 'Oggi è una bella giornata.');

        expect(elements[1], isA<NoteImageElement>());
        expect(elements[1].content, 'https://example.com/image.jpg');

        expect(elements[2], isA<NoteAudioElement>());
        expect(elements[2].content, 'https://example.com/audio.mp3');

        // Fallback al testo per tipi sconosciuti
        expect(elements[3], isA<NoteTextElement>());
        expect(elements[3].content, 'Testo di fallback');
      });

      test(
        'dovrebbe gestire campi mancanti con valori di default di sicurezza',
        () {
          // Arrange
          final json = readFixture('note_incomplete.json');

          // Act
          final result = NoteDTO.fromJson(json);

          // Assert
          expect(result.id, '');
          expect(result.title, 'Nuova Nota');
          expect(result.noteElements, isEmpty);

          final now = DateTime.now();
          expect(
            now.difference(result.creationDate).inSeconds.abs(),
            lessThan(2),
          );
          expect(
            now.difference(result.updateDate).inSeconds.abs(),
            lessThan(2),
          );
        },
      );

      test(
        'dovrebbe gestire date formattate male facendo fallback a DateTime.now()',
        () {
          // Arrange
          final json = {
            'created_at': 'data-non-valida',
            'updated_at': 'data-non-valida',
          };

          // Act
          final result = NoteDTO.fromJson(json);

          // Assert
          final now = DateTime.now();
          expect(
            now.difference(result.creationDate).inSeconds.abs(),
            lessThan(2),
          );
          expect(
            now.difference(result.updateDate).inSeconds.abs(),
            lessThan(2),
          );
        },
      );
    });

    group('toJson', () {
      test('dovrebbe serializzare correttamente un oggetto Note in JSON', () {
        // Arrange
        final note = LocalNote(
          id: 'note_456',
          title: 'Appunti',
          creationDate: DateTime.utc(2023, 11, 20, 9, 0, 0),
          lastModified: DateTime.utc(2023, 11, 20, 10, 0, 0),
          initialElements: [
            NoteTextElement('Testo 1'),
            NoteImageElement('path/to/image.png', File('path/to/image.png')),
          ],
        );

        // Act
        final result = NoteDTO.toJson(note);

        // Assert
        expect(result['note_id'], 'note_456');
        expect(result['title'], 'Appunti');
        expect(result['created_at'], '2023-11-20T09:00:00.000Z');
        expect(result['updated_at'], '2023-11-20T10:00:00.000Z');

        final elementsJson = result['elements'] as List<Map<String, dynamic>>;
        expect(elementsJson.length, 2);

        expect(elementsJson[0]['type'], 'text');
        expect(elementsJson[0]['content'], 'Testo 1');

        expect(elementsJson[1]['type'], 'image');
        expect(elementsJson[1]['content'], 'path/to/image.png');
      });

      test('dovrebbe serializzare correttamente una nota senza elementi', () {
        // Arrange
        final note = LocalNote(
          id: 'note_empty',
          title: 'Vuota',
          creationDate: DateTime.utc(2024, 1, 1),
          lastModified: DateTime.utc(2024, 1, 1),
          initialElements: [],
        );

        // Act
        final result = NoteDTO.toJson(note);

        // Assert
        expect(result['elements'], isEmpty);
      });
    });
  });
}
