import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';

///Classe che fa da intermediario tra Service e ViewModel
///
///Si occupa di gestire i risultati dei tentativi di accesso dell'utente

class DiaryAccountRepository {
  final DiaryAccountService _service;
  DiaryAccountRepository(this._service);

  Future<DiaryAccessResult> clarifyAccessResult(String pwd) async {
    int result = await _service.validateDiaryPassword(pwd);
    switch (result) {
      case 0:
        return DiaryAccessResult.error;
      case 1:
        return DiaryAccessResult.realDiary;
      case 2:
        return DiaryAccessResult.fakeDiary;
      case 3:
        return DiaryAccessResult.tooManyAttempts;
      default:
        return DiaryAccessResult.error;
    }
  }

  /// Validazione nuova password diario fittizio se tutto ok ritorna null, altrimenti ritorna stringa di errore
  Future<String> registerFakeDiaryPassword(String pwd) async {
    if (pwd.isEmpty) {
      return "La password non può essere vuota";
    }

    if (pwd.length < 10 ||
        !pwd.contains(RegExp(r"[A-Z]")) ||
        !pwd.contains(RegExp(r"[a-z]")) ||
        !pwd.contains(RegExp(r"[0-9]")) ||
        !pwd.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ||
        pwd.contains(RegExp(r"[\s]"))) {
      return "Inserire una password valida";
    } else {
      int check = await _service.registerFakeDiaryPassword(pwd);
      switch (check) {
        case 1:
          return "La password del diario fittizio non può essere identica alla password del diario reale";
        case 2:
          return "La nuova password deve essere diversa da quella attualmente in uso";

        default:
          return "";
      }
    }
  }
}
