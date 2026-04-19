import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

/// Classe che gestisce la sessione della funzionalità dei diari
///
/// Implementa il pattern Singleton tramite il campo statico _session e il suo getter statico, in modo da rendere
/// le informazioni sulla sessione accessibili dalle altre parti della funzionalità e fare in modo che esista solo una sessione attiva in un dato momento.
class DiarySession {
  static final DiarySession _session = DiarySession._internal();

  bool? isDiaryAuth;
  DiaryType? loggedDiary;
  DiarySession._internal() {
    isDiaryAuth = false;
  }
  factory DiarySession() {
    return _session;
  }

  /// Getter per la sessione
  static DiarySession get session => _session;

  /// Metodi

  /// Inizializza la sessione per il [DiaryType] specificato
  void initSession(DiaryType diaryType) async {
    isDiaryAuth = true;
    loggedDiary = diaryType;

    const storage = FlutterSecureStorage();
    await storage.write(key: "isDiaryAuth", value: isDiaryAuth.toString());
    await storage.write(key: "loggedDiary", value: loggedDiary.toString());
  }

  /// Termina la sessione
  void endSession() async {
    isDiaryAuth = false;
    loggedDiary = null;
    const storage = FlutterSecureStorage();
    await Future.wait([
      storage.delete(key: "isDiaryAuth"),
      storage.delete(key: "loggedDiary"),
    ]);
  }
}
