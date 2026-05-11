import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import '../../../utils/cache_manager.dart';
import '../../../utils/locator.dart';
import '../../../domain/models/auth/user.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/dead_man_repository.dart';

/// Gestisce lo stato della UI per l'autenticazione e coordina le azioni dell'utente.
class AuthViewModel extends ChangeNotifier {
  /// Repository per l'accesso ai dati di autenticazione.
  final AuthRepository _authRepository;

  /// Comando per l'esecuzione del login.
  late final Command<void, void> login;

  /// Comando per l'esecuzione del logout.
  late final Command<void, void> logout;

  bool isInitializing = true;

  /// Inizializza il view model configurando i comandi reattivi.
  AuthViewModel(this._authRepository) {
    login = Command.createAsyncNoParamNoResult(_login);
    logout = Command.createAsyncNoParamNoResult(_logout);
  }

  /// Restituisce l'utente attualmente autenticato.
  User? get currentUser => _authRepository.getCurrentUser();

  /// Verifica se esiste una sessione utente attiva nel repository.
  Future<void> checkExistingSession() async {
    isInitializing = true;
    notifyListeners();

    if (!_authRepository.isLoggedIn()) {
      await _authRepository.restoreSession();
    }

    if (_authRepository.isLoggedIn()) {
      final deadManRepo = getIt<DeadManRepository>();

      try {
        await deadManRepo.createSettings();
      } catch (e) {
        debugPrint("Errore creazione settings: $e");
      }

      try {
        await deadManRepo.sendHeartbeat();
        debugPrint("Heartbeat inviato con successo al login!");
      } catch (e) {
        debugPrint("Attenzione: Impossibile inviare l'Heartbeat al login: $e");
      }
    }

    isInitializing = false;
    notifyListeners();
  }

  /// Logica interna per la procedura di login.
  Future<void> _login() async {
    final user = await _authRepository.login();
    if (user == null) {
      throw Exception('Autenticazione fallita o annullata dall\'utente.');
    }

    notifyListeners();
  }

  /// Logica interna per la procedura di logout.
  Future<void> _logout() async {
    await _authRepository.logout();

    getIt<CacheManager>().clearAllCaches();

    notifyListeners();
  }
}
