import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class DiarySession {
  late DiaryType _diaryType;
  bool isAuth = false;
  static DiarySession? _instance;

  DiarySession._(DiaryType type, bool authStatus);

  factory DiarySession(DiaryType type, bool authStatus) {
    _instance ??= DiarySession._(type, authStatus);
    return _instance!;
  }

  void initSession(bool authStatus, DiaryType diaryType) {
    DiarySession(diaryType, authStatus);
  }

  void endSession() {
    DiarySession._instance = null;
  }

  bool isAuthenticated() {
    return isAuth;
  }

  DiaryType getDiaryType() {
    return _diaryType;
  }

  static DiarySession getDiaryInstance() {
    return DiarySession(
      DiarySession._instance!.getDiaryType(),
      DiarySession._instance!.isAuthenticated(),
    );
  }
}
