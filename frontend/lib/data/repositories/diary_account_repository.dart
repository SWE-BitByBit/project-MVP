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

  /// Valida la password e mappa l'esito del backend in un enumeratore comprensibile alla UI.
  Future<DiaryAccessResult> clarifyAccessResult(String pwd) async {
    try {
      // Ora il servizio restituisce una Map (es. {'token': '...', 'diary_type': 'REAL_DIARY'})
      final Map<String, dynamic> response = await _service.validateDiaryPassword(pwd);
      final String? typeStr = response['diary_type'];
      final String? token = response['token'];

      if (token != null && typeStr != null) {
        final diaryType = typeStr == 'real_diary' ? DiaryType.real_diary : DiaryType.fake_diary;
        await DiarySession.session.initSession(diaryType, token);

        return typeStr == 'real_diary' ? DiaryAccessResult.real_diary : DiaryAccessResult.fake_diary;
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

  /// Validazione nuova password diario fittizio.
  /// Se tutto è ok ritorna null o stringa vuota, altrimenti ritorna la stringa di errore.
  Future<String> registerFakeDiaryPassword(String pwd) async {
    if (pwd.isEmpty) {
      return "La password non può essere vuota";
    }

    // Validazione robusta lato client
    if (pwd.length < 10 ||
        !pwd.contains(RegExp(r"[A-Z]")) ||
        !pwd.contains(RegExp(r"[a-z]")) ||
        !pwd.contains(RegExp(r"[0-9]")) ||
        !pwd.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ||
        pwd.contains(RegExp(r"\s"))) {
      return "Inserire una password valida";
    } else {
      try {
        // Supponendo che questo metodo chiami un endpoint POST /diary/fake/password
        final response = await _service.registerFakeDiaryPassword(pwd);
        if (response['error'] == 'IDENTICAL_TO_REAL') {
          return "La password del diario fittizio non può essere identica alla password del diario reale";
        }
        if (response['error'] == 'SAME_AS_CURRENT') {
          return "La nuova password deve essere diversa da quella attualmente in uso";
        }
        return "";
      } catch (e) {
        return "Errore imprevisto durante la registrazione della password.";
      }
    }
  }

  /// Richiede al servizio di aggiornare la password reale del diario
  Future<String> registerRealDiaryPassword(String pwd) async {
    if (pwd.isEmpty) {
      return "La password non può essere vuota";
    }

    // Validazione robusta lato client
    if (pwd.length < 10 ||
        !pwd.contains(RegExp(r"[A-Z]")) ||
        !pwd.contains(RegExp(r"[a-z]")) ||
        !pwd.contains(RegExp(r"[0-9]")) ||
        !pwd.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ||
        pwd.contains(RegExp(r"\s"))) {
      return "Inserire una password valida";
    } else {
      try {
        // Supponendo che questo metodo chiami un endpoint POST /diary/real/password
        final response = await _service.registerRealDiaryPassword(pwd);
        if (response['error'] == 'SAME_AS_CURRENT') {
          return "La nuova password deve essere diversa da quella attualmente in uso";
        }
        return "";
      } catch (e) {
        return "Errore imprevisto durante la registrazione della password.";
      }
    }
  }

  /// Controlla se il diario reale è già stato inizializzato con una password.
  Future<bool> checkHasRealPassword() async {
    try {
      return await _service.checkHasRealPassword();
    } catch (e) {
      // In caso di errore di rete, assumiamo che non ci sia per mostrare il form di setup
      // (oppure potresti rilanciare l'errore per mostrare un banner "Connessione assente")
      return false;
    }
  }
}