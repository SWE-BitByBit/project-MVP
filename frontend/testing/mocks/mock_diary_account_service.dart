import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';

class MockDiaryAccountService implements DiaryAccountService {
  int returnValue = -1;
  @override
  Future<int> validateDiaryPassword(String pwd) async {
    return returnValue;
  }

  String duplicatePw = "";
  @override
  Future<int> registerFakeDiaryPassword(String pwd) async {
    if (pwd == duplicatePw) {
      return 1;
    } else {
      return 0;
    }
  }
}
