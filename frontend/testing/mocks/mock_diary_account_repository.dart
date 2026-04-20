import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';

class MockDiaryAccountRepository implements DiaryAccountRepository {
  @override
  DiaryAccessResult clarifyAccessResult(String pwd) {
    switch (pwd) {
      case "real":
        return DiaryAccessResult.realDiary;
      case "fake":
        return DiaryAccessResult.fakeDiary;
      case "error":
        return DiaryAccessResult.error;
      case "tooMany":
        return DiaryAccessResult.tooManyAttempts;
    }
    return DiaryAccessResult.error;
  }
}
