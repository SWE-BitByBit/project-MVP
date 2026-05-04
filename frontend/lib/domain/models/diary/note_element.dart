import 'dart:io';

/// Classe base astratta per gli elementi delle note.
abstract class NoteElement {
  /// Contenuto dell'elemento (testo, path dell'immagine o dell'audio).
  /// Essendo pubblica, Dart crea in automatico getter e setter efficienti.
  String content;
  File? file;
  String? noteParentId;
  String? noteElementId;

  NoteElement(this.content,  {this.file, this.noteParentId, this.noteElementId});

  /// Getter astratto che definisce il tipo dell'elemento.
  /// Ogni sottoclasse DEVE implementarlo.
  String get type;

}
