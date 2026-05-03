import '../../domain/models/diary/diary_enums.dart';
import '../../domain/models/diary/diary_session.dart';
import '../services/diary_account_service.dart';
import '../network/api_exception.dart'; // Assumendo che questa sia la tua classe per le eccezioni di rete

/// Classe che fa da intermediario tra ViewModel e Service per l'accesso ai diari.
///
/// Si occupa di gestire i tentativi di accesso e di registrare nuove credenziali.
class DiaryAccountRepository {
  final DiaryAccountService _service;

  DiaryAccountRepository(this._service);

  /// Valida la password e ritorna l'esito del tentativo di accesso.
  Future<DiaryAccessResult> clarifyAccessResult(String pwd) async {
    try {
      final Map<String, dynamic> response = await _service
          .validateDiaryPassword(pwd);
      final String? typeStr = response['diary_type'];
      final String? token = response['access_token'];

      if (token != null && typeStr != null) {
        final diaryType = typeStr == 'REAL_DIARY'
            ? DiaryType.real_diary
            : DiaryType.fake_diary;
        await DiarySession.session.initSession(diaryType, token);

        return typeStr == 'REAL_DIARY'
            ? DiaryAccessResult.real_diary
            : DiaryAccessResult.fake_diary;
      }

      return DiaryAccessResult.error;
    } on ApiException catch (e) {
      if (e.statusCode == 429) {
        return DiaryAccessResult.too_many_attempts;
      }
      return DiaryAccessResult.error;
    } catch (e) {
      return DiaryAccessResult.error;
    }
  }

  /// Metodo unificato per impostare o modificare la password (reale o fittizia).
  /// Se tutto è ok ritorna una stringa vuota, altrimenti ritorna la stringa di errore.
  Future<String> setPassword({
    String? oldPassword,
    required String newPassword,
    required DiaryType diaryType,
  }) async {
    if (newPassword.isEmpty) {
      return "La password non può essere vuota";
    }

    if (newPassword.length < 10 ||
        !newPassword.contains(RegExp(r"[A-Z]")) ||
        !newPassword.contains(RegExp(r"[a-z]")) ||
        !newPassword.contains(RegExp(r"[0-9]")) ||
        !newPassword.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ||
        newPassword.contains(RegExp(r"\s"))) {
      return "Inserire una password valida";
    }

    try {
      final response = await _service.setPassword(
        oldPassword,
        newPassword,
        diaryType,
      );

      if (response == null) {
        return "";
      }

      // Gestione degli errori unificata dal backend
      if (response['error'] == 'IDENTICAL_TO_REAL') {
        return "La password del diario fittizio non può essere identica alla password del diario reale";
      }
      if (response['error'] == 'SAME_AS_CURRENT') {
        return "La nuova password deve essere diversa da quella attualmente in uso";
      }
      return "";
    } catch (e) {
      if (e is ApiException) {
        print(e.message);
        if (e.message.toString().startsWith(
          "Previous password does not match",
        )) {
          return "La password inserita non è corretta";
        }
      }
      return "Errore imprevisto durante la registrazione della password.";
    }
  }

  /// Controlla se il diario reale è già stato inizializzato con una password.
  Future<bool> checkHasRealPassword() async {
    try {
      return await _service.checkHasRealPassword();
    } catch (e) {
      return false;
    }
  }
}
