import '../../domain/models/safeplace/safe_place.dart';
import '../../domain/models/safeplace/safe_place_enums.dart';

/// DTO per la mappatura dei dati tra API e Dominio.
abstract class SafePlaceDTO {
  /// Mappa il JSON grezzo del backend nel modello di dominio [SafePlace].
  static SafePlace fromJson(Map<String, dynamic> json) {
    return SafePlace(
      id: json['marker_id'] as String? ?? json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Luogo senza nome',
      address: json['address'] as String? ?? 'Indirizzo non disponibile',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      category: _mapCategory(json['category'] as String?),
    );
  }

  /// Estrae un double in modo sicuro, sia che il JSON contenga un numero, sia una stringa.
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Traduce le categorie del database (Italiano) nell'Enum strongly-typed di Flutter.
  static SafePlaceCategory _mapCategory(String? categoryRaw) {
    final cat = categoryRaw?.toLowerCase().trim();
    switch (cat) {
      case 'ospedale':
      case 'pronto soccorso':
        return SafePlaceCategory.hospital;
      case 'polizia':
      case 'carabinieri':
      case 'questura':
        return SafePlaceCategory.police;
      case 'farmacia':
        return SafePlaceCategory.pharmacy;
      case 'centro_antiviolenza':
      case 'rifugio':
        return SafePlaceCategory.emergencyShelter;
      default:
        return SafePlaceCategory.other;
    }
  }
}
