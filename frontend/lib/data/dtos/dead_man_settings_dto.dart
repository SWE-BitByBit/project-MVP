import '../../domain/models/dead_man/dead_man_settings.dart';

/// DTO responsabile della conversione della configurazione del Dead Man's Switch
/// tra il formato JSON e il modello di Dominio.
abstract class DeadManSettingsDTO {
  /// Traduce il [json] proveniente dall'API in un'istanza immutabile di [DeadManSettings].
  static DeadManSettings fromJson(Map<String, dynamic> json) {
    return DeadManSettings(
      isActive: _parseBool(json['is_active'] ?? json['isActive']),

      firstInactivityTimer: json['first_timer'] as int? ?? 60,
      secondInactivityTimer: json['second_timer'] as int? ?? 15,

      messageSubject:
          json['email_subject'] as String? ?? 'Emergenza: Mancato Check-in',
      messageBody:
          json['email_body'] as String? ??
          'Non ho confermato il mio stato di sicurezza.',
    );
  }

  /// Converte l'istanza di [settings] in una mappa JSON per l'invio ad AWS.
  static Map<String, dynamic> toJson(DeadManSettings settings) {
    return {
      'is_active': settings.isActive,
      'first_timer': settings.firstInactivityTimer,
      'second_timer': settings.secondInactivityTimer,
      'email_subject': settings.messageSubject,
      'email_body': settings.messageBody,
    };
  }

  /// Utility per gestire backend che inviano booleani in formati strani.
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
