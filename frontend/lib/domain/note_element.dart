abstract class NoteElement {
  String _content = '';

  NoteElement();

  void setContent(String content) {
    _content = content;
  }

  String getContent() {
    return _content;
  }

  String getType() {
    return '';
  }
}
