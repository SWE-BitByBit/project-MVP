import '../../domain/resource.dart';
import '../../domain/resource_type.dart';

/// Classe responsabile della traduzione dei dati grezzi dal backend
/// nel formato di dominio [Resource] utilizzato dall'applicazione.
class ResourceDTO {
  static Resource fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Senza Titolo',
      content: json['content'] as String?,
      url: json['url'] as String?,
      type: _parseResourceType(json['type'] as String?),
    );
  }

  static Map<String, dynamic> toJson(Resource resource) {
    return {
      'id': resource.id,
      'title': resource.title,
      'content': resource.content,
      'url': resource.url,
      'type': resource.type.name,
    };
  }

  static ResourceType _parseResourceType(String? typeString) {
    if (typeString == null) return ResourceType.article;

    return ResourceType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeString.toLowerCase(),
      orElse: () => ResourceType.article,
    );
  }
}
