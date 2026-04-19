/// Classe astratta per gli elementi delle [Note]
abstract class NoteElement {
  String _content = '';

  NoteElement();

  /// Getter
  /// Ritorna il contenuto dell'elemento
  String getContent() {
    return _content;
  }

  /// Ritorna il tipo dell'elemento
  String getType() {
    return '';
  }

  /// Imposta il contenuto
  void setContent(String content) {
    _content = content;
  }
}
