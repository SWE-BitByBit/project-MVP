import '../../domain/models/safeplace/safe_place.dart';

/// DTO (Data Transfer Object) per la gestione della conversione dei dati.
/// Trasforma il JSON proveniente dalle API nel formato di dominio [SafePlace] e viceversa.
class SafePlaceDTO {
  /// Converte un payload JSON in un'istanza del dominio [SafePlace].
  static SafePlace fromJson(Map<String, dynamic> json) {
    return SafePlace(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      // Usiamo 'num' e poi '.toDouble()' per evitare errori a runtime
      // se l'API invia un intero (es. 45) invece di un decimale (es. 45.0)
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  /// Converte un'istanza del dominio [SafePlace] in una mappa JSON.
  static Map<String, dynamic> toJson(SafePlace place) {
    return {
      'id': place.id,
      'name': place.name,
      'address': place.address,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'category': place.category,
    };
  }
}
