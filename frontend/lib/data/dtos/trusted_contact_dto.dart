import '../../domain/trusted_contact.dart';

/// Oggetto di trasferimento dati per la serializzazione dei contatti fidati.
/// Mappa i dati JSON del backend verso il Dominio e viceversa.
class TrustedContactDTO {
  TrustedContactDTO._(); // Costruttore privato: contiene solo metodi statici.

  /// Converte un JSON ricevuto dal backend in un oggetto di dominio [TrustedContact].
  static TrustedContact fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  /// Converte un oggetto [TrustedContact] in un formato JSON per il backend.
  static Map<String, dynamic> toJson(TrustedContact contact) {
    return {
      'id': contact.getId(),
      'name': contact.getName(),
      'email': contact.getEmail(),
      'phoneNumber': contact.getPhone(),
    };
  }
}
