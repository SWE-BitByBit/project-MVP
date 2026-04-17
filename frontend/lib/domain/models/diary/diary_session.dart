import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class DiarySession {
  static final DiarySession _session = DiarySession._internal();
  static DiarySession get session => _session;
  bool? isDiaryAuth;
  DiaryType? loggedDiary;
  DiarySession._internal() {
    isDiaryAuth = false;
  }
  factory DiarySession() {
    return _session;
  }

  void initSession(DiaryType diaryType) async {
    isDiaryAuth = true;
    loggedDiary = diaryType;

    const storage = FlutterSecureStorage();
    await storage.write(key: "isDiaryAuth", value: isDiaryAuth.toString());
    await storage.write(key: "loggedDiary", value: loggedDiary.toString());
  }

  Future<void> loadSession() async {
    const storage = FlutterSecureStorage();
    final response = await Future.wait([
      storage.read(key: "isDiaryAuth"),
      storage.read(key: "loggedDiary"),
    ]);
    if (response[0] != null) {
      isDiaryAuth = bool.tryParse(response[0]!);
    }
    if (response[1] != null) {
      loggedDiary = DiaryType.values.byName(response[1]!);
    }
  }

  void endSession() async {
    isDiaryAuth = null;
    loggedDiary = null;
    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: "isDiaryAuth"),
      storage.delete(key: "loggedDiary"),
    ]);
  }
}
