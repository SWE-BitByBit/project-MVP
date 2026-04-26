/// Rappresenta un contatto fidato nel dominio dell'applicazione.
///
/// Contiene le informazioni anagrafiche essenziali per identificare e
/// contattare una persona di fiducia in caso di emergenza.
class TrustedContact {
  /// L'identificativo univoco del contatto (generato dal backend).
  final String id;

  /// Il nome completo o l'etichetta assegnata al contatto.
  String name;

  /// L'indirizzo email del contatto.
  String email;

  /// Il numero di telefono comprensivo di prefisso internazionale.
  String phoneNumber;

  /// Crea un'istanza di [TrustedContact].
  ///
  /// Richiede [id], [name], [email] e [phoneNumber] come parametri obbligatori.
  TrustedContact({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  /// Crea una copia di questo contatto con alcuni campi sostituiti.
  ///
  /// Metodo utile per aggiornare il contatto in modo immutabile se necessario.
  TrustedContact copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}