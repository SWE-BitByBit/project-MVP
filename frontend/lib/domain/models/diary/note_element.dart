import 'dart:io';

/// Classe base astratta per gli elementi delle note.
abstract class NoteElement {
  /// Contenuto dell'elemento (testo, path dell'immagine o dell'audio).
  /// Essendo pubblica, Dart crea in automatico getter e setter efficienti.
  String content;
  String? note_parent_id;
  String? note_element_id;

  NoteElement(this.content);

  /// Getter astratto che definisce il tipo dell'elemento.
  /// Ogni sottoclasse DEVE implementarlo.
  String get type;

  void setFile(File file);

  File? get file;
}
