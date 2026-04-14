import 'package:flutter/material.dart';
import '../../../../domain/user.dart';
import '../../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per l'autenticazione e coordina le azioni dell'utente.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  /// Inizializza il view model con un'istanza di [authRepository].
  AuthViewModel(this._authRepository);

  /// Indica se è in corso un'operazione asincrona (mostra la rotellina di caricamento).
  bool get isLoading => _isLoading;

  /// Contiene un eventuale messaggio di errore da mostrare all'utente.
  String? get errorMessage => _errorMessage;

  /// Restituisce l'utente corrente ottenuto dal repository.
  User? get currentUser => _authRepository.getCurrentUser();

  /// Avvia la procedura di login, aggiornando lo stato della UI.
  Future<void> login() async {
    _setLoading(true);
    _errorMessage = null; // Resettiamo eventuali errori precedenti

    try {
      final user = await _authRepository.login();
      if (user == null) {
        _errorMessage = 'Autenticazione fallita o annullata.';
      }
    } catch (e) {
      _errorMessage = 'Si è verificato un errore di connessione.';
    } finally {
      // finally viene eseguito SEMPRE, sia che vada bene, sia che vada in errore.
      // Spegniamo la rotellina di caricamento.
      _setLoading(false);
    }
  }

  /// Avvia la procedura di logout e notifica la UI.
  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.logout();
    _setLoading(false);
  }

  /// Aggiorna lo stato di caricamento locale e notifica la grafica.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Questo è il comando magico che aggiorna lo schermo!
  }
}
