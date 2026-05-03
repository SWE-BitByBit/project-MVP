import 'dart:io';
import 'note_element.dart';

/// Classe per gli elementi delle note che contengono immagini
abstract class NoteMediaElement extends NoteElement {
  NoteMediaElement(super.content, this.file, this.url);

  File file;
  String url;


}