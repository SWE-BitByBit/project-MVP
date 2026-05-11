import '../../domain/models/trusted_contact/trusted_contact.dart';

/// Mapper responsabile della conversione dei dati tra il formato JSON del backend
/// e l'oggetto di dominio [TrustedContact].
abstract class TrustedContactDTO {
  /// Trasforma un oggetto JSON [data] in un oggetto [TrustedContact].
  static TrustedContact fromJson(Map<String, dynamic> data) {
    return TrustedContact(
      id: (data['contactId'] ?? data['contact_id'])?.toString() ?? '',
      name: (data['name'] ?? data['contact_name'])?.toString() ?? '',
      email: (data['email'] ?? data['contact_email'])?.toString() ?? '',
      phoneNumber: (data['phoneNumber'] ?? data['contact_phone_number'])?.toString() ?? '',
    );
  }

  /// Converte un oggetto [contact] di tipo [TrustedContact] in una mappa JSON.
  static Map<String, dynamic> toJson(TrustedContact contact) {
    return {
      'contactId': contact.id,
      'name': contact.name,
      'email': contact.email,
      'phoneNumber': contact.phoneNumber,
      'contact_id': contact.id,
      'contact_name': contact.name,
      'contact_email': contact.email,
      'contact_phone_number': contact.phoneNumber,
    };
  }
}
