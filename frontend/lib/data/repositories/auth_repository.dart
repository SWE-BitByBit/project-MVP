import 'dart:convert';
import '../../domain/user.dart';
import '../dtos/user_dto.dart';
import '../services/auth_service.dart';

/// Coordina l'accesso ai dati di autenticazione.
/// Agisce da tramite tra il livello di servizio ([AuthService]) e il livello UI.
class AuthRepository {
  final AuthService _authService;
  User? _currentUser;

  /// Inizializza il repository con un'istanza di [authService].
  AuthRepository(this._authService);

  /// Restituisce l'utente attualmente autenticato, se presente.
  User? getCurrentUser() => _currentUser;

  /// Verifica se esiste un utente attualmente autenticato.
  bool isLoggedIn() => _currentUser != null;

  /// Avvia il processo di login delegando l'operazione di rete al servizio.
  /// In caso di successo, converte i dati grezzi in un oggetto [User] e lo salva.
  Future<User?> login() async {
    try {
      // 1. Chiediamo al motore (Service) di fare il lavoro sporco su internet
      final Map<String, dynamic> rawData = await _authService.login();

      // 2. Trasformiamo la mappa grezza in una stringa JSON
      final String jsonString = jsonEncode(rawData);

      // 3. Usiamo il traduttore (DTO) per creare l'utente pulito
      _currentUser = UserDTO.fromJson(jsonString);

      return _currentUser;
    } catch (e) {
      print('Errore nel Repository durante il login: $e');
      return null;
    }
  }

  /// Esegue il logout dell'utente corrente e cancella i dati in memoria.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
  }
}
