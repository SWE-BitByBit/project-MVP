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
}
