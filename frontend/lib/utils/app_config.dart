import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe centralizzata per tutte le configurazioni d'ambiente
class AppConfig {
  /// Recupera l'URL base dell'API.
  /// Fornisce un fallback di sicurezza nel caso il file .env sia mancante.
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:3000';
  }

// Esempio se avessi porte diverse:
// static String get diariesApiUrl => dotenv.env['DIARIES_API_URL'] ?? 'http://127.0.0.1:3001';
}