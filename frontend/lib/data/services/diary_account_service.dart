import '../network/api_client.dart';
import '../../domain/models/diary/diary_enums.dart';

/// Servizio responsabile della sicurezza e dell'accesso al diario.
///
/// Gestisce la validazione della password dedicata tramite il sistema Argon2id
/// implementato lato backend.
class DiaryAccountService {
  final ApiClient _apiClient;

  /// Percorso base per le API del diario.
  static const String _basePath = '/diary/auth';

  DiaryAccountService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Valida la password del diario e ottiene il token di sessione.
  ///
  /// Corrisponde all'endpoint [POST /diary/auth/].
  /// [password] La password inserita dall'utente.
  /// [return] Una mappa contenente 'token' e 'diary_type' (REAL_DIARY/FAKE_DIARY).
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
  ///
  /// Se [oldPassword] è nullo, si assume che sia la prima attivazione.
  Future<Map<String, dynamic>> setPassword(String? oldPassword, String newPassword, DiaryType diaryType) async {
    final body = <String, dynamic>{
      'new_password': newPassword,
      'diary_type': diaryType == DiaryType.real_diary ? 'real_diary' : 'fake_diary',
    };
    if (oldPassword != null) {
      body['old_password'] = oldPassword;
    }

    final response = await _apiClient.post(
      '$_basePath/set-password',
      body: body,
      requiresAuth: true,
    );

    return response as Map<String, dynamic>;
  }

  /// Interroga il backend per sapere se l'utente ha già impostato la password del diario.
  Future<bool> checkHasRealPassword() async {
    try {
      // Ipotizziamo che il backend esponga un endpoint GET per lo stato del diario.
      // Esempio: restituisce { "has_password": true }
      final response = await _apiClient.get(
        '$_basePath/status', // Oppure l'endpoint che ti fornirà il backend
        requiresAuth: true,
      );

      // Converte la risposta in un booleano (adatta la chiave 'has_password' a quella del tuo JSON reale)
      return response['has_password'] == true;

    } catch (e) {
      // Se la chiamata fallisce (es. 404 Not Found), gestiamo l'errore in modo sicuro

      return false;
    }
  }


}