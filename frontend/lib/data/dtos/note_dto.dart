import '../../domain/models/diary/note.dart';
import '../../domain/models/diary/local_note.dart';
import '../../domain/models/diary/note_element.dart';
import '../../domain/models/diary/note_text_element.dart';
import '../../domain/models/diary/note_audio_element.dart';
import '../../domain/models/diary/note_image_element.dart';

/// Oggetto di trasferimento dati per la serializzazione delle Note.
/// Mappa in modo sicuro i dati JSON del backend verso il Dominio e viceversa.
abstract class NoteDTO {
  /// Converte un JSON in un oggetto di Dominio [LocalNote].
  static Note fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawElements = json['elements'] ?? [];

    final List<NoteElement> parsedElements = rawElements.map((elemJson) {
      final type = elemJson['type']?.toString();
      final content = elemJson['content']?.toString() ?? '';

      switch (type) {
        case 'image':
          return NoteImageElement(content);
        case 'audio':
          return NoteAudioElement(content);
        case 'text':
        default:
          return NoteTextElement(content);
      }
    }).toList();

    final creationStr = json['created_at']?.toString();
    final updateStr = json['updated_at']?.toString();
    final creationDate = DateTime.tryParse(creationStr ?? '') ?? DateTime.now();
    final updateDate = DateTime.tryParse(updateStr ?? '') ?? creationDate;

    return LocalNote(
      id: json['note_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Nuova Nota',
      creationDate: creationDate,
      lastModified: updateDate,
      initialElements: parsedElements,
    );
  }

  /// Converte un oggetto [Note] in un formato JSON per il Backend.
  static Map<String, dynamic> toJson(Note note) {
    final List<Map<String, dynamic>> elementsJson = note.noteElements.map((
      elem,
    ) {
      return {'type': elem.type, 'content': elem.content};
    }).toList();

    return {
      'note_id': note.id,
      'title': note.title,
      'created_at': note.creationDate.toIso8601String(),
      'updated_at': note.updateDate.toIso8601String(),
      'elements': elementsJson,
    };
  }
}
