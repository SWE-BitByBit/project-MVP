import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';

void main() {
  group("DiaryAccessViewmodel", () {
    late DiaryAccessViewmodel viewmodel;
    late MockDiaryAccountRepository repo;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      FlutterSecureStorage.setMockInitialValues({});
      repo = MockDiaryAccountRepository();
      viewmodel = DiaryAccessViewmodel(repo);
    });

    test("Stato iniziale", () {
      expect(viewmodel.error, isNull);
    });

    test(
      "login crea la sessione correttamente se accesso effettuato con successo",
      () async {
        DiarySession session = DiarySession();
        String result = await viewmodel.login("real");
        expect(result, "");
        expect(session.isDiaryAuth, true);
        expect(session.loggedDiary, DiaryType.realDiary);
      },
    );
    test("logout termina la sessione correttamente", () async {
      DiarySession session = DiarySession();
      viewmodel.login("real");
      viewmodel.logout();
      expect(session.isDiaryAuth, false);
      expect(session.loggedDiary, null);
    });
  });
}
