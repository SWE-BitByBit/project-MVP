import 'package:flutter/foundation.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/auth_service.dart';

/// Implementazione finta (Mock) di [AuthService] per i test.
class MockAuthService implements AuthService {
  /// Se [true], simula un errore di rete.
  bool shouldThrowError = false;

  /// Valore di ritorno programmabile per il metodo [login].
  Map<String, dynamic>? mockedTokenResponse;

  @override
  Future<Map<String, dynamic>> login() async {
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato in AuthService.login');
    }
    return mockedTokenResponse ?? {
      'access_token': 'mock_access_token',
      'id_token': 'mock_id_token',
      'refresh_token': 'mock_refresh_token',
      'expires_in': 3600,
    };
  }

  @override
  Future<void> logout() async {
    if (shouldThrowError) {
      debugPrint('Errore durante il logout di rete (simulato)');
    }
    // Successo immediato
  }
}
