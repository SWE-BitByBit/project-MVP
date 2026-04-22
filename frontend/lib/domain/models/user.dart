/// Rappresenta l'entità utente all'interno del livello di dominio dell'applicazione.
/// Questa classe è pura e non contiene logica di conversione dati.
class User {
  final String sub;
  final String email;
  final String name;
  final String surname;
  final String idToken;
  final String accessToken;
  final String? refreshToken;

  /// Inizializza un'istanza di [User] con i parametri obbligatori e opzionali.
  const User({
    required this.sub,
    required this.email,
    required this.name,
    required this.surname,
    required this.idToken,
    required this.accessToken,
    this.refreshToken,
  });
}
