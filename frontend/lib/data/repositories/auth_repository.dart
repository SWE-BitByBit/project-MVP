import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/user.dart';
import '../dtos/user_dto.dart';
import '../services/auth_service.dart';

/// Coordina l'accesso ai dati di autenticazione.
///
/// Agisce da tramite tra il livello di servizio ([AuthService]) e il livello UI,
/// gestendo lo stato dell'utente tramite [_currentUser].
class AuthRepository {
  /// Servizio per le operazioni di rete con AWS Cognito.
  final AuthService _authService;

  /// Utente attualmente autenticato nella sessione locale.
  User? _currentUser;

  /// Inizializza il repository con un'istanza di [_authService].
  AuthRepository(this._authService);

  /// Restituisce l'utente attualmente memorizzato in [_currentUser], se presente.
  User? getCurrentUser() => _currentUser;

  /// Verifica se esiste un utente attualmente autenticato controllando [_currentUser].
  bool isLoggedIn() => _currentUser != null;

  /// Avvia il processo di login delegando l'operazione di rete a [_authService].
  ///
  /// In caso di successo, converte i dati grezzi in un oggetto [User] e lo salva
  /// nella variabile [_currentUser].
  Future<User?> login() async {
    try {
      final Map<String, dynamic> rawData = await _authService.login();
      final String jsonString = jsonEncode(rawData);
      _currentUser = UserDTO.fromJson(jsonString);

      return _currentUser;
    } catch (e) {
      debugPrint('Errore nel Repository durante il login: $e');
      return null;
    }
  }

  /// Esegue il logout dell'utente tramite [_authService] e resetta [_currentUser].
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
  }
}
