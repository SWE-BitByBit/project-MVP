import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

class DiaryAccessViewmodel with ChangeNotifier {
  final DiaryAccountRepository _accRepo = DiaryAccountRepository();

  //Inizializza diarySession se (un) login ha successo, altrimenti ritorna stringa di errore.
  String login(String pwd) {
    switch (_accRepo.clarifyAccessResult(pwd)) {
      case DiaryAccessResult.realDiary:
        final diarySession = DiarySession.session;
        diarySession.initSession(DiaryType.realDiary);
        return 'Login effettuato con successo.';
      case DiaryAccessResult.fakeDiary:
        final diarySession = DiarySession.session;
        diarySession.initSession(DiaryType.fakeDiary);
        return 'Login effettuato con successo.';
      case DiaryAccessResult.error:
        return 'Errore nel login.';
      case DiaryAccessResult.tooManyAttempts:
        return 'Troppi tentativi di login effettuati. Si è pregati di riprovare più tardi.';
    }
  }

  //Termina la sessione
  String logout() {
    final diarySession = DiarySession.session;
    diarySession.endSession();
    return 'Logout effettuato con successo.';
  }
}
