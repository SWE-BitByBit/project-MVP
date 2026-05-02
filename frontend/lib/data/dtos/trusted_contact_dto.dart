import '../../domain/models/trusted_contact/trusted_contact.dart';

/// Mapper responsabile della conversione dei dati tra il formato JSON del backend
/// e l'oggetto di dominio [TrustedContact].
abstract class TrustedContactDTO {
  /// Trasforma un oggetto JSON [data] in un oggetto [TrustedContact].
  static TrustedContact fromJson(Map<String, dynamic> data) {
    return TrustedContact(
      id: data['contact_id']?.toString() ?? '',
      name: data['contact_name']?.toString() ?? '',
      email: data['contact_email']?.toString() ?? '',
      phoneNumber: data['contact_phone_number']?.toString() ?? '',
    );
  }

  /// Converte un oggetto [contact] di tipo [TrustedContact] in una mappa JSON.
  static Map<String, dynamic> toJson(TrustedContact contact) {
    return {
      'contact_id': contact.id,
      'contact_name': contact.name,
      'contact_email': contact.email,
      'contact_phone_number': contact.phoneNumber,
    };
  }
}
