import 'resource_type.dart';

/// Rappresenta un singolo elemento di materiale informativo.
///
/// Questa classe è indipendente dalla sorgente dati e viene utilizzata
/// dalla UI per mostrare le informazioni all'utente.
class Resource {
  /// Identificatore univoco della risorsa.
  final String id;

  /// Il titolo o nome della risorsa.
  final String title;

  /// Il testo completo della risorsa, se disponibile.
  final String? content;

  /// Il collegamento esterno (link) associato alla risorsa.
  final String? url;

  /// La categoria a cui appartiene la risorsa.
  final ResourceType type;

  /// Inizializza un'istanza di risorsa.
  const Resource({
    required this.id,
    required this.title,
    this.content,
    this.url,
    required this.type,
  });
}
