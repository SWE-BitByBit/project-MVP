import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';

void main() {
  setUp(() {
    // Inizializza i mock per flutter_secure_storage
    FlutterSecureStorage.setMockInitialValues({});

    // Reset manuale dello stato del Singleton prima di ogni test
    DiarySession.session.isDiaryAuth = false;
    DiarySession.session.loggedDiary = null;
    DiarySession.session.token = null;
  });

  group('DiarySession', () {
    test('initSession dovrebbe aggiornare lo stato e salvare i dati nello storage', () async {
      // act
      await DiarySession.session.initSession(DiaryType.real_diary, 'test_token');

      // assert
      expect(DiarySession.session.isDiaryAuth, true);
      expect(DiarySession.session.loggedDiary, DiaryType.real_diary);
      expect(DiarySession.session.token, 'test_token');

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'isDiaryAuth'), 'true');
      expect(await storage.read(key: 'loggedDiary'), 'DiaryType.real_diary');
      expect(await storage.read(key: 'sessionToken'), 'test_token');
    });

    test('restoreSession dovrebbe ripristinare la sessione di un real_diary se i dati corretti sono presenti', () async {
      // arrange
      // NOTA: Il codice originale cerca 'diaryToken' e confronta il tipo con la stringa esatta 'real_diary'
      FlutterSecureStorage.setMockInitialValues({
        'isDiaryAuth': 'true',
        'loggedDiary': 'real_diary',
        'diaryToken': 'restored_token_123',
      });

      // act
      final result = await DiarySession.session.restoreSession();

      // assert
      expect(result, true);
      expect(DiarySession.session.isDiaryAuth, true);
      expect(DiarySession.session.loggedDiary, DiaryType.real_diary);
      expect(DiarySession.session.token, 'restored_token_123');
    });

    test('restoreSession dovrebbe ripristinare la sessione di un fake_diary se type non è real_diary', () async {
      // arrange
      FlutterSecureStorage.setMockInitialValues({
        'isDiaryAuth': 'true',
        'loggedDiary': 'fake_diary',
        'diaryToken': 'restored_fake_token',
      });

      // act
      final result = await DiarySession.session.restoreSession();

      // assert
      expect(result, true);
      expect(DiarySession.session.loggedDiary, DiaryType.fake_diary);
      expect(DiarySession.session.token, 'restored_fake_token');
    });

    test('restoreSession dovrebbe restituire false se i dati nello storage mancano o sono incompleti', () async {
      // arrange
      FlutterSecureStorage.setMockInitialValues({
        'isDiaryAuth': 'true',
        // manca loggedDiary e diaryToken
      });

      // act
      final result = await DiarySession.session.restoreSession();

      // assert
      expect(result, false);
    });

    test('endSession dovrebbe resettare lo stato interno e pulire lo storage', () async {
      // arrange
      await DiarySession.session.initSession(DiaryType.real_diary, 'test_token');

      // act
      await DiarySession.session.endSession();

      // assert
      expect(DiarySession.session.isDiaryAuth, false);
      expect(DiarySession.session.loggedDiary, isNull);
      expect(DiarySession.session.token, isNull);

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'isDiaryAuth'), isNull);
      expect(await storage.read(key: 'loggedDiary'), isNull);
      expect(await storage.read(key: 'sessionToken'), isNull);
    });
  });
}