import '../../domain/models/safeplace/safe_place.dart';
import '../../domain/models/safeplace/safe_place_enums.dart';

/// DTO per la mappatura dei dati tra API e Dominio.
abstract class SafePlaceDTO {
  /// Mappa il JSON grezzo del backend nel modello di dominio [SafePlace].
  static SafePlace fromJson(Map<String, dynamic> json) {
    return SafePlace(
      // 1. Risolve il mismatch dell'ID (cerca 'marker_id', se non c'è prova 'id')
      id: json['marker_id'] as String? ?? json['id'] as String? ?? 'unknown',

      name: json['name'] as String? ?? 'Luogo senza nome',
      address: json['address'] as String? ?? 'Indirizzo non disponibile',

      // 2. Risolve il mismatch delle coordinate (converte le Stringhe in double)
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),

      // 3. Risolve il mismatch delle categorie (traduce il DB italiano nell'Enum)
      category: _mapCategory(json['category'] as String?),
    );
  }

  /// Converte il modello di dominio in JSON per l'invio al backend (se necessario in futuro).
  static Map<String, dynamic> toJson(SafePlace place) {
    return {
      'marker_id': place.id,
      'name': place.name,
      'address': place.address,
      'latitude': place.latitude.toString(), // Il backend lo vuole come stringa
      'longitude': place.longitude.toString(),
      'category': place.category.name,
    };
  }

  // --- HELPER PRIVATI PER IL PARSING SICURO ---

  /// Estrae un double in modo sicuro, sia che il JSON contenga un numero, sia una stringa.
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0; // Fallback di sicurezza in caso di null o formato errato
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