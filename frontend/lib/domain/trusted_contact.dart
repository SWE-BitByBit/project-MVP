/// Rappresenta un singolo contatto fidato nel formato consumato dal layer UI.
///
/// Questa classe è indipendente da qualsiasi sorgente dati e
/// contiene le informazioni anagrafiche e di recapito del contatto.
class TrustedContact {
  final String _id;
  String _name;
  String _email;
  String _phoneNumber;

  /// Crea un'istanza di [TrustedContact] con i dati identificativi del contatto.
  ///
  /// Tutti i parametri sono obbligatori e rappresentano rispettivamente
  /// l'identificativo univoco, il nome completo, l'email e il numero di telefono.
  TrustedContact({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
  })  : _id = id,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber;

  /// Restituisce l'identificativo univoco del contatto.
  String getId() => _id;

  /// Restituisce il nome completo del contatto.
  String getName() => _name;

  /// Restituisce l'indirizzo email del contatto.
  String getEmail() => _email;

  /// Restituisce il numero di telefono del contatto.
  String getPhone() => _phoneNumber;

  /// Aggiorna il nome completo del contatto.
  void setName(String name) {
    _name = name;
  }

  /// Aggiorna l'indirizzo email del contatto.
  void setEmail(String email) {
    _email = email;
  }

  /// Aggiorna il numero di telefono del contatto.
  void setPhone(String phoneNumber) {
    _phoneNumber = phoneNumber;
  }
}
