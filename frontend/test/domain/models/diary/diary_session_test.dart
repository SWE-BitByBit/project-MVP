import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

void main() {
  group("DiarySession", () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      FlutterSecureStorage.setMockInitialValues({});
    });
    test("initSession crea una sessione correttamente", () async {
      DiarySession sampleSession = DiarySession.session;
      await sampleSession.initSession(DiaryType.realDiary);

      expect(sampleSession.isDiaryAuth, true);
      expect(sampleSession.loggedDiary, DiaryType.realDiary);
    });

    test("può esistere solo una sessione di DiarySession", () {
      DiarySession sampleSession1 = DiarySession.session;
      DiarySession sampleSession2 = DiarySession.session;
      expect(sampleSession1 == sampleSession2, true);
    });

    test("endSession termina correttamente la sessione", () {
      DiarySession sampleSession = DiarySession.session;
      sampleSession.initSession(DiaryType.realDiary);

      sampleSession.endSession();

      expect(sampleSession.isDiaryAuth, false);
      expect(sampleSession.loggedDiary, null);
    });
  });
}
