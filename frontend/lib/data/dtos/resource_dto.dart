import '../../domain/models/material/resource.dart';
import '../../domain/models/material/resource_type.dart';

/// Classe responsabile della traduzione dei dati grezzi dal backend
/// nel formato di dominio [Resource] utilizzato dall'applicazione.
class ResourceDTO {
  /// Traduce la mappa [json] proveniente dall'API in un'istanza di [Resource].
  static Resource fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['resource_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Senza Titolo',
      content: json['content'] as String?,
      url: json['url'] as String?,
      type: _parseResourceType(json['type'] as String?),
    );
  }

  /// Converte l'istanza di [resource] in una mappa JSON.
  static Map<String, dynamic> toJson(Resource resource) {
    return {
      'id': resource.id,
      'title': resource.title,
      'content': resource.content,
      'url': resource.url,
      'type': resource.type.name,
    };
  }

  /// Converte la stringa [typeString] nell'enumerativo [ResourceType] corrispondente.
  static ResourceType _parseResourceType(String? typeString) {
    if (typeString == null) return ResourceType.article;

    return ResourceType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeString.toLowerCase(),
      orElse: () => ResourceType.article,
    );
  }
}
