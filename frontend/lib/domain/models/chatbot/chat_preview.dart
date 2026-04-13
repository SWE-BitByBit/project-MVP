/// Rappresenta l'anteprima di una chat mostrata nella lista della cronologia.
class ChatPreview {
  final String id;
  final String title;
  final DateTime lastModified;

  ChatPreview({
    required this.id,
    required this.title,
    required this.lastModified,
  });
}