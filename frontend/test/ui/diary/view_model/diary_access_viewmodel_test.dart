import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

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
      "login crea la sessione correttamente se accesso effettuato con successo, altrimenti no",
      () async {
        DiarySession session = DiarySession();
        String res1 = await viewmodel.login("real");
        expect(res1, "");
        expect(session.isDiaryAuth, true);
        expect(session.loggedDiary, DiaryType.realDiary);
        session.endSession();

        String res2 = await viewmodel.login("fake");
        expect(res2, "");
        expect(session.isDiaryAuth, true);
        expect(session.loggedDiary, DiaryType.fakeDiary);
        session.endSession();

        String res3 = await viewmodel.login("error");
        expect(res3, "Errore nel login.");
        expect(session.isDiaryAuth, false);
        expect(session.loggedDiary, isNull);
        session.endSession();

        String res4 = await viewmodel.login("tooMany");
        expect(
          res4,
          "Troppi tentativi di login effettuati. Si è pregati di riprovare più tardi.",
        );
        expect(session.isDiaryAuth, false);
        expect(session.loggedDiary, isNull);
        session.endSession();
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
