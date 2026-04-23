import 'package:mvp_app_protegge_e_trasforma/data/services/auth_service.dart';
import 'dart:convert';

class MockAuthService implements AuthService {
  bool shouldThrowError = false;
  Map<String, dynamic>? mockedTokenResponse;

  // Generiamo un JWT finto ma valido per non far crashare il DTO
  String _generateFakeJwt() {
    final payload = jsonEncode({"email": "test@example.com", "sub": "mock-sub-123"});
    final base64Payload = base64UrlEncode(utf8.encode(payload));
    return 'header.$base64Payload.signature';
  }

  @override
  Future<Map<String, dynamic>> login() async {
    if (shouldThrowError) throw Exception('Errore di rete simulato');

    return mockedTokenResponse ?? {
      'access_token': 'mock_access_token',
      'id_token': _generateFakeJwt(),
      'refresh_token': 'mock_refresh_token',
    };
  }

  @override
  Future<void> logout() async {
    if (shouldThrowError) throw Exception('Errore logout');
  }

}