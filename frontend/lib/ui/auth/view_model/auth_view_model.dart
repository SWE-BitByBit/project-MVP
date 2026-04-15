import 'package:flutter/material.dart';
import '../../../../domain/user.dart';
import '../../../../data/repositories/auth_repository.dart';

/// Gestisce lo stato della UI per l'autenticazione e coordina le azioni dell'utente.
///
/// Utilizza [_authRepository] per eseguire le operazioni di accesso e aggiorna
/// lo stato di [_isLoading] e [_errorMessage].
class AuthViewModel extends ChangeNotifier {
  /// Repository per l'accesso ai dati di autenticazione.
  final AuthRepository _authRepository;

  /// Indica se è in corso un'operazione di caricamento.
  bool _isLoading = false;

  /// Messaggio di errore da visualizzare nella UI in caso di fallimento.
  String? _errorMessage;

  /// Inizializza il view model associando l'istanza di [_authRepository].
  AuthViewModel(this._authRepository);

  /// Indica se è in corso un'operazione asincrona (mostra la rotellina di caricamento).
  bool get isLoading => _isLoading;

  /// Contiene un eventuale messaggio di errore da mostrare all'utente.
  String? get errorMessage => _errorMessage;

  /// Restituisce l'utente corrente recuperandolo direttamente da [_authRepository].
  User? get currentUser => _authRepository.getCurrentUser();

  /// Avvia la procedura di login tramite [_authRepository], aggiornando lo stato della UI.
  Future<void> login() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authRepository.login();
      if (user == null) {
        _errorMessage = 'Autenticazione fallita o annullata.';
      }
    } catch (e) {
      _errorMessage = 'Si è verificato un errore di connessione.';
    } finally {
      _setLoading(false);
    }
  }

  /// Avvia la procedura di logout richiamando [_authRepository] e notifica la UI.
  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.logout();
    _setLoading(false);
  }

  /// Aggiorna lo stato di caricamento tramite [value] e notifica i listener della grafica.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
