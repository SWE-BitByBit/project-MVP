import 'package:flutter/foundation.dart';
import '../../domain/models/auth/user.dart';
import '../dtos/user_dto.dart';
import '../services/auth_service.dart';

/// Coordina l'accesso ai dati di autenticazione.
///
/// Agisce da tramite tra il livello di servizio ([AuthService]) e il livello UI,
/// gestendo lo stato dell'utente tramite la variabile privata [_currentUser].
class AuthRepository {
  /// Servizio per le operazioni di rete con AWS Cognito.
  final AuthService _authService;

  /// Utente attualmente autenticato nella sessione locale.
  User? _currentUser;

  /// Inizializza il repository con l'istanza di [_authService] iniettata.
  AuthRepository(this._authService);

  /// Restituisce l'utente attualmente memorizzato in [_currentUser].
  User? getCurrentUser() => _currentUser;

  /// Verifica se esiste un utente autenticato controllando la presenza di [_currentUser].
  bool isLoggedIn() => _currentUser != null;

  /// Avvia il login delegando l'operazione a [_authService].
  ///
  /// In caso di successo, mappa i dati tramite [UserDTO] e aggiorna lo stato.
  /// Restituisce un [Future] con l'oggetto [User] o [null] in caso di fallimento.
  Future<User?> login() async {
    try {
      final Map<String, dynamic> rawData = await _authService.login();
      _currentUser = UserDTO.fromJson(rawData);
      return _currentUser;
    } catch (e) {
      debugPrint('Errore nel Repository durante il login: $e');
      return null;
    }
  }

  /// Esegue il logout chiamando il servizio di rete e resettando [_currentUser].
  ///
  /// Restituisce un [Future] di tipo [void].
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      // Resettiamo sempre l'utente locale anche se la chiamata di rete fallisce

      _currentUser = null;
    }
  }
}