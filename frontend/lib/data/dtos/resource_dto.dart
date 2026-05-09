import '../../domain/models/material/resource.dart';
import '../../domain/models/material/resource_type.dart';

/// Classe responsabile della traduzione dei dati grezzi dal backend
/// nel formato di dominio [Resource] utilizzato dall'applicazione.
abstract class ResourceDTO {

  /// Traduce la mappa [json] proveniente dall'API in un'istanza di [Resource].
  static Resource fromJson(Map<String, dynamic> json) {
    return Resource(
      id: (json['resource_id']?.toString() ?? 'unknown'),
      title: json['title'] as String? ?? 'Risorsa senza titolo',
      content: json['content'] as String?,
      url: json['url'] as String?,
      type: ResourceType.fromString(json['type'] as String?),
    );
  }

  /// Converte l'istanza di [resource] in una mappa JSON per il backend.
  static Map<String, dynamic> toJson(Resource resource) {
    return {
      'resource_id': resource.id,
      'title': resource.title,
      'content': resource.content,
      'url': resource.url,
      'type': resource.type.name,
    };
  }
}