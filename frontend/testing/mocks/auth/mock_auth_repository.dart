import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/user.dart';

class MockAuthRepository implements AuthRepository {
  User? _mockedUser;
  bool shouldThrowError = false;

  @override
  User? getCurrentUser() => _mockedUser;

  @override
  bool isLoggedIn() => _mockedUser != null;

  @override
  Future<User?> login() async {
    // Re-inserite le condizioni che avevi originariamente!
    if (shouldThrowError) throw Exception('Autenticazione fallita');

    _mockedUser = const User(
      sub: 'mock-id-123',
      email: 'test@example.com',
      name: 'Test',
      surname: 'Visitor',
      idToken: 'mock_it',
      accessToken: 'mock_at',
      refreshToken: 'mock_rt',
    );
    return _mockedUser;
  }

  @override
  Future<void> logout() async {
    _mockedUser = null;
  }

  void setMockedUser(User? user) {
    _mockedUser = user;
  }
}