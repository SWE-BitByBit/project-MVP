import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';

class DiaryAccountRepository {
  DiaryAccessResult clarifyAccessResult(String pwd) {
    int result = DiaryAccountService().validateDiaryPassword(pwd);
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
