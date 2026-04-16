import '../../domain/resource.dart';
import '../../domain/resource_type.dart';

/// Classe responsabile della traduzione dei dati grezzi dal backend
/// nel formato di dominio [Resource] utilizzato dall'applicazione.
class ResourceDTO {
  /// Converte una mappa JSON proveniente dal backend in un oggetto [Resource].
  ///
  /// Gestisce la conversione della stringa del tipo in enum [ResourceType]
  /// e mappa i campi opzionali in modo sicuro.
  static Resource fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String? ?? '', // Gestione sicura del null
      title: json['title'] as String? ?? 'Senza Titolo',
      content: json['content'] as String?,
      url: json['url'] as String?,
      type: _parseResourceType(json['type'] as String?),
    );
  }

  /// Converte un oggetto [Resource] in una mappa JSON per l'invio al backend.
  static Map<String, dynamic> toJson(Resource resource) {
    return {
      'id': resource.id,
      'title': resource.title,
      'content': resource.content,
      'url': resource.url,
      'type': resource.type.name,
    };
  }

  /// Metodo di supporto per convertire in modo sicuro la stringa del backend
  /// nel corrispondente [ResourceType].
  /// Se il tipo non è riconosciuto, viene restituito [ResourceType.article] come fallback.
  static ResourceType _parseResourceType(String? typeString) {
    if (typeString == null) return ResourceType.article;

    return ResourceType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeString.toLowerCase(),
      orElse: () => ResourceType.article,
    );
  }
}
