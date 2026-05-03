import 'dart:io';

import '../../domain/models/diary/note_element.dart';
import '../../domain/models/diary/note_text_element.dart';
import '../../domain/models/diary/note_image_element.dart';
import '../../domain/models/diary/note_audio_element.dart';

abstract class NoteElementDTO {
  /// Converte un JSON in un oggetto di Dominio [NoteElement]
  static NoteElement fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString();
    final content = json['content']?.toString() ?? '';
    final noteId = json['note_id']?.toString();
    final elementId = json['note_element_id']?.toString();

    switch (type) {
      case 'image':
        return NoteImageElement(
          content,
          File(content),
          noteParentId: noteId,
          noteElementId: elementId,
        );

      case 'audio':
        return NoteAudioElement(
          content,
          File(content),
          noteParentId: noteId,
          noteElementId: elementId,
        );

      case 'text':
      default:
        return NoteTextElement(
          content,
          noteParentId: noteId,
          noteElementId: elementId,
        );
    }
  }

  static Map<String, dynamic> toJson(NoteElement element) {
    return {
      'note_id': element.noteParentId,
      'note_element_id': element.noteElementId,
      'type': element.type,
      'content': element.content,
    };
  }
}
