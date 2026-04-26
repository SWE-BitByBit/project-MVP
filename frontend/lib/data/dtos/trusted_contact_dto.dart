import '../../domain/models/trusted_contact/trusted_contact.dart';

/// Mapper responsabile della conversione dei dati tra il formato JSON del backend
/// e l'oggetto di dominio [TrustedContact].
abstract class TrustedContactDTO {
  /// Costruttore privato per impedire l'istanziazione, essendo una classe di utility.

  /// Trasforma una mappa JSON [data] proveniente dall'API in un oggetto [TrustedContact].
  ///
  /// Gestisce eventuali valori nulli assegnando stringhe vuote come default.
  static TrustedContact fromJson(Map<String, dynamic> data) {
    return TrustedContact(
      id: data['contactId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
    );
  }

  /// Converte un oggetto [contact] di tipo [TrustedContact] in una mappa JSON.
  ///
  /// Questo formato è quello richiesto dal backend per le operazioni di POST e PUT.
  static Map<String, dynamic> toJson(TrustedContact contact) {
    return {
      'contactId': contact.id,
      'name': contact.name,
      'email': contact.email,
      'phoneNumber': contact.phoneNumber,
    };
  }
}