import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../domain/models/diary/diary_enums.dart';

/// Classe che gestisce la sessione della funzionalità dei diari
class DiarySession {
  static final DiarySession _session = DiarySession._internal();

  bool? isDiaryAuth;
  DiaryType? loggedDiary;
  String? token;

  DiarySession._internal() {
    isDiaryAuth = false;
  }
  factory DiarySession() {
    return _session;
  }

  /// Getter per la sessione
  static DiarySession get session => _session;

  /// Inizializza la sessione per il [DiaryType] specificato
  Future<void> initSession(DiaryType diaryType, String sessionToken) async {
    isDiaryAuth = true;
    loggedDiary = diaryType;
    token = sessionToken;

    const storage = FlutterSecureStorage();
    await storage.write(key: "isDiaryAuth", value: isDiaryAuth.toString());
    await storage.write(key: "loggedDiary", value: loggedDiary.toString());
    await storage.write(key: "sessionToken", value: token);
  }

  Future<bool> restoreSession() async {
    const storage = FlutterSecureStorage();

    final storedAuth = await storage.read(key: "isDiaryAuth");
    final storedType = await storage.read(key: "loggedDiary");
    final storedToken = await storage.read(key: "diaryToken");

    if (storedAuth == "true" && storedType != null && storedToken != null) {
      isDiaryAuth = true;
      token = storedToken;

      if (storedType == "real_diary") {
        loggedDiary = DiaryType.real_diary;
      } else {
        loggedDiary = DiaryType.fake_diary;
      }
      return true;
    }

    return false;
  }

  /// Termina la sessione
  Future<void> endSession() async {
    isDiaryAuth = false;
    loggedDiary = null;
    token = null;
    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: "isDiaryAuth"),
      storage.delete(key: "loggedDiary"),
      storage.delete(key: "sessionToken"),
    ]);
  }
}
