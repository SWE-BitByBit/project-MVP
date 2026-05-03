import '../network/api_client.dart';
import '../../domain/models/diary/diary_enums.dart';

/// Servizio responsabile della sicurezza e dell'accesso al diario.
class DiaryAccountService {
  final ApiClient _apiClient;

  /// Percorso base per le API del diario.
  static const String _basePath = '/diary/auth';

  DiaryAccountService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Valida la password del diario e ottiene il token di sessione.
  Future<Map<String, dynamic>> validateDiaryPassword(String password) async {
    final body = {'password': password};

    final response = await _apiClient.post(
      '$_basePath/login',
      body: body,
      requiresAuth: true,
    );

    return response as Map<String, dynamic>;
  }

  /// Imposta o aggiorna la password (Reale o Fittizia).
  Future<Map<String, dynamic>?> setPassword(
    String? oldPassword,
    String newPassword,
    DiaryType diaryType,
  ) async {
    final body = <String, dynamic>{
      'password': newPassword,
      'diary_type': diaryType == DiaryType.real_diary
          ? 'REAL_DIARY'
          : 'FAKE_DIARY',
    };
    if (oldPassword != null) {
      body['previous_password'] = oldPassword;
    }

    final response = await _apiClient.post(
      '$_basePath/set_password',
      body: body,
      requiresAuth: true,
    );

    return response as Map<String, dynamic>?;
  }

  /// Interroga il backend per sapere se l'utente ha già impostato la password del diario.
  Future<bool> checkHasRealPassword() async {
    try {
      // Ipotizziamo che il backend esponga un endpoint GET per lo stato del diario.
      final response = await _apiClient.get(
        '$_basePath/status',
        requiresAuth: true,
      );

      return response['has_real_password'] == true;
    } catch (e) {
      return false;
    }
  }
}
