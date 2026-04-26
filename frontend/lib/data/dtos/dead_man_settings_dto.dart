import '../../domain/models/dead_man/dead_man_settings.dart';

/// DTO responsabile della conversione della configurazione del Dead Man's Switch
/// tra il formato JSON (usato da AWS / Local Storage) e il modello di Dominio.
abstract class DeadManSettingsDTO {

  /// Traduce la mappa [json] proveniente dall'API in un'istanza immutabile di [DeadManSettings].
  static DeadManSettings fromJson(Map<String, dynamic> json) {
    return DeadManSettings(
      // Parsing robusto dei booleani (a volte i server mandano 1/0 o stringhe)
      isActive: _parseBool(json['is_active'] ?? json['isActive']),

      // Fallback a valori di sicurezza se il server non li fornisce
      firstInactivityTimer: json['first_inactivity_timer'] as int? ?? 60,
      secondInactivityTimer: json['second_inactivity_timer'] as int? ?? 15,

      // Assicuriamoci che i testi non siano mai nulli
      messageSubject: json['message_subject'] as String? ?? 'Emergenza: Mancato Check-in',
      messageBody: json['message_body'] as String? ?? 'Non ho confermato il mio stato di sicurezza.',
    );
  }

  /// Converte l'istanza di [settings] in una mappa JSON per l'invio ad AWS.
  static Map<String, dynamic> toJson(DeadManSettings settings) {
    return {
      'is_active': settings.isActive,
      'first_inactivity_timer': settings.firstInactivityTimer,
      'second_inactivity_timer': settings.secondInactivityTimer,
      'message_subject': settings.messageSubject,
      'message_body': settings.messageBody,
    };
  }

  // --- HELPER PRIVATO ---

  /// Utility per gestire backend che inviano booleani in formati strani.
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}