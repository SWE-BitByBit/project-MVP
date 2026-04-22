import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/user.dart';


/// Implementazione finta (Mock) di [AuthRepository] per i test.
class MockAuthRepository implements AuthRepository {
  /// Utente corrente simulato.
  User? _mockedUser;
  
  /// Se [true], simula un valore nullo restituito dal repository (es. annullamento).
  bool shouldThrowError = false;

  /// Se [true], simula un'eccezione lanciata dal repository (es. errore connessione).
  bool shouldThrowException = false;

  @override
  User? getCurrentUser() => _mockedUser;

  @override
  bool isLoggedIn() => _mockedUser != null;

  @override
  Future<User?> login() async {
    if (shouldThrowException) {
      throw Exception('Connessione fallita');
    }
    if (shouldThrowError) return null;
    
    _mockedUser = const User(
      sub: 'mock-id-123',
      email: 'test@example.com',
      name: 'Test',
      surname: 'Visitor',
      idToken: 'mock_it',
      accessToken: 'mock_at',
    );
    return _mockedUser;
  }

  @override
  Future<void> logout() async {
    _mockedUser = null;
  }

  /// Permette di impostare l'utente corrente per i test (es. simulare utente già loggato).
  void setMockedUser(User? user) {
    _mockedUser = user;
  }
}
