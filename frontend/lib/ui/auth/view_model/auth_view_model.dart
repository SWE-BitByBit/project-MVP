import 'package:flutter/material.dart';
import '../../../../domain/user.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../utils/command.dart';

/// Gestisce lo stato della UI per l'autenticazione e coordina le azioni dell'utente.
///
/// Utilizza [_authRepository] per eseguire le operazioni di accesso e aggiorna
/// lo stato di [_isLoading] e [_errorMessage].
class AuthViewModel extends ChangeNotifier {
  /// Repository per l'accesso ai dati di autenticazione.
  final AuthRepository _authRepository;

  /// Comando reattivo per avviare il login
  late final Command0<void> login;

  /// Comando reattivo per avviare il logout
  late final Command0<void> logout;

  /// Inizializza il view model associando l'istanza di [_authRepository].
  AuthViewModel(this._authRepository) {
    login = Command0<void>(_login);
    logout = Command0<void>(_logout);
  }

  /// Restituisce l'utente corrente recuperandolo direttamente da [_authRepository].
  User? get currentUser => _authRepository.getCurrentUser();

  /// Controlla se esiste una sessione utente valida e notifica i listener.
  void checkExistingSession() {
    if (_authRepository.getCurrentUser() != null) {
      notifyListeners();
    }
  }

  /// Avvia la procedura di login tramite [_authRepository].
  Future<void> _login() async {
    try {
      final user = await _authRepository.login();
      if (user == null) {
        throw Exception('Autenticazione fallita o annullata.');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Autenticazione fallita')) {
        rethrow;
      }
      throw Exception('Si è verificato un errore di connessione.');
    }
  }

  /// Avvia la procedura di logout richiamando [_authRepository].
  Future<void> _logout() async {
    await _authRepository.logout();
  }
}
