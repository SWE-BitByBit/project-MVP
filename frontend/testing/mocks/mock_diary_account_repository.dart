import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';

class MockDiaryAccountRepository implements DiaryAccountRepository {
  bool shouldThrowError = false;
  Duration simulatedDelay = Duration.zero;

  @override
  Future<DiaryAccessResult> clarifyAccessResult(String pwd) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (shouldThrowError) {
      throw Exception('Errore di rete simulato durante clarifyAccessResult');
    }
    switch (pwd) {
      case "real":
        return DiaryAccessResult.realDiary;
      case "fake":
        return DiaryAccessResult.fakeDiary;
      case "error":
        return DiaryAccessResult.error;
      case "tooMany":
        return DiaryAccessResult.tooManyAttempts;
      default:
        return DiaryAccessResult.error;
    }
  }
}
