import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import '../../../utils/cache_manager.dart';
import '../../../utils/locator.dart';
import '../../../domain/models/auth/user.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/dead_man_repository.dart';

/// Gestisce lo stato della UI per l'autenticazione e coordina le azioni dell'utente.
///
/// Questa classe funge da ponte tra la View e l' [AuthRepository], esponendo
/// le azioni tramite il pattern [Command].
class AuthViewModel extends ChangeNotifier {
  /// Repository per l'accesso ai dati di autenticazione.
  final AuthRepository _authRepository;

  /// Comando per l'esecuzione del login.
  /// 
  /// Espone lo stato di esecuzione e gli eventuali errori alla View.
  late final Command<void, void> login;

  /// Comando per l'esecuzione del logout.
  late final Command<void, void> logout;

  /// Inizializza il view model configurando i comandi reattivi.
  /// 
  /// Riceve l'istanza di [_authRepository] tramite Dependency Injection.
  AuthViewModel(this._authRepository) {
    // Usiamo una funzione anonima (_) per ignorare il parametro void richiesto.
    // Passiamo initialValue: null come richiesto dal costruttore.
    login = Command.createAsyncNoParamNoResult(_login);
    logout = Command.createAsyncNoParamNoResult(_logout);
  }

  /// Restituisce l'utente attualmente autenticato.
  User? get currentUser => _authRepository.getCurrentUser();

  /// Verifica se esiste una sessione utente attiva nel repository.
  /// 
  /// Notifica i listener se l'utente è presente per aggiornare la navigazione.
  void checkExistingSession() {
    if (_authRepository.isLoggedIn()) {
      notifyListeners();
    }
  }

  /// Logica interna per la procedura di login.
  /// 
  /// Interagisce con [_authRepository] per ottenere l'oggetto [User].
  /// Solleva un'eccezione in caso di fallimento che verrà catturata dal comando.
  Future<void> _login() async {
    final user = await _authRepository.login();
    if (user == null) {
      throw Exception('Autenticazione fallita o annullata dall\'utente.');
    }
    try {
      final deadManRepo = getIt<DeadManRepository>();
      await deadManRepo.sendHeartbeat();
      debugPrint("Heartbeat inviato con successo al login!");
    } catch (e) {
      debugPrint("Attenzione: Impossibile inviare l'Heartbeat al login: $e");
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