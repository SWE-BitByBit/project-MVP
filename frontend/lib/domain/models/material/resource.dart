import 'resource_type.dart';

/// Rappresenta un singolo elemento di materiale informativo.
///
/// Questa classe è indipendente dalla sorgente dati e viene utilizzata
/// dalla UI per mostrare le informazioni all'utente. Include campi opzionali
/// per adattarsi a diverse tipologie di risorse (es. link esterni vs testi interni).
class Resource {
  /// Identificatore univoco della risorsa.
  final String id;

  /// Il titolo o nome della risorsa.
  final String title;

  /// Il testo completo, i paragrafi o la descrizione della risorsa (opzionale).
  final String? content;

  /// Il collegamento esterno (link) associato alla risorsa (opzionale).
  final String? url;

  /// La categoria a cui appartiene la risorsa, definita tramite [ResourceType].
  final ResourceType type;

  /// Inizializza un'istanza di risorsa.
  ///
  /// I parametri [content] e [url] sono opzionali per consentire
  /// risorse puramente testuali o puramente basate su link.
  Resource({
    required this.id,
    required this.title,
    this.content,
    this.url,
    required this.type,
  });
}
