import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/user.dart';


/// Implementazione finta (Mock) di [AuthRepository] per i test.
class MockAuthRepository implements AuthRepository {
  /// Utente corrente simulato.
  User? _mockedUser;
  
  /// Se [true], simula un errore durante il login.
  bool shouldThrowError = false;

  @override
  User? getCurrentUser() => _mockedUser;

  @override
  bool isLoggedIn() => _mockedUser != null;

  @override
  Future<User?> login() async {
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
