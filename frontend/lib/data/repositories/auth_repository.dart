import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth/user.dart';
import '../dtos/user_dto.dart';
import '../services/auth_service.dart';

/// Coordina l'accesso ai dati di autenticazione.
///
/// Agisce da tramite tra il livello di servizio ([AuthService]) e il livello UI.
class AuthRepository {
  /// Servizio per le operazioni di rete con AWS Cognito.
  final AuthService _authService;

  final _secureStorage = const FlutterSecureStorage();
  final String _refreshTokenKey = 'cognito_refresh_token';

  /// Utente attualmente autenticato nella sessione locale.
  User? _currentUser;

  /// Inizializza il repository con l'istanza di [_authService] iniettata.
  AuthRepository(this._authService);

  /// Restituisce l'utente attualmente autenticato.
  User? getCurrentUser() => _currentUser;

  /// Verifica se esiste un utente autenticato
  bool isLoggedIn() => _currentUser != null;

  /// Avvia il login.
  ///
  /// In caso di successo, mappa i dati tramite [UserDTO] e aggiorna lo stato.
  /// Restituisce un [Future] con l'oggetto [User] o [null] in caso di fallimento.
  Future<User?> login() async {
    try {
      final Map<String, dynamic> rawData = await _authService.login();
      _currentUser = UserDTO.fromJson(rawData);

      if (rawData.containsKey('refresh_token')) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: rawData['refresh_token'],
        );
      }

      return _currentUser;
    } catch (e) {
      debugPrint('Errore nel Repository durante il login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _currentUser = null;
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  Future<bool> restoreSession() async {
    try {
      final savedRefreshToken = await _secureStorage.read(
        key: _refreshTokenKey,
      );

      if (savedRefreshToken == null) {
        return false;
      }
      final Map<String, dynamic> rawData = await _authService.refreshToken(
        savedRefreshToken,
      );
      _currentUser = UserDTO.fromJson(rawData);
      return true;
    } catch (e) {
      debugPrint('Impossibile ripristinare la sessione (token scaduto?): $e');
      await _secureStorage.delete(key: _refreshTokenKey);
      return false;
    }
  }
}
