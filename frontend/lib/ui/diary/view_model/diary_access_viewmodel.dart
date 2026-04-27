import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';

/// Classe che gestisce logica di presentazione e stato dell'interfaccia per l'accesso alla funzionalità dei
/// diari. Fa uso del mixin [ChangeNotifier] per notificare i widget in ascolto quando avvengono
/// cambiamenti di stato.
class DiaryAccessViewmodel with ChangeNotifier {
  final DiaryAccountRepository _accRepo;

  ///Crea istanza di [DiaryAccessViewmodel] con il [DiaryAccountRepository] specificato
  DiaryAccessViewmodel(this._accRepo);

  ///Stato UI
  String? _error;

  bool _accessStatus = false;

  /// Ritorna l'ultimo errore, altrimenti ritorna null
  String? get error => _error;

  bool get accessStatus => _accessStatus;

  //Inizializza diarySession se il login ha successo, altrimenti ritorna stringa di errore.
  Future<String> login(String pwd) async {
    try {
      notifyListeners();
      DiaryAccessResult res = await _accRepo.clarifyAccessResult(pwd);
      switch (res) {
        case DiaryAccessResult.realDiary:
          final diarySession = DiarySession.session;
          diarySession.initSession(DiaryType.realDiary);
          _accessStatus = true;

        case DiaryAccessResult.fakeDiary:
          final diarySession = DiarySession.session;
          diarySession.initSession(DiaryType.fakeDiary);
          _accessStatus = true;

        case DiaryAccessResult.error:
          _error = 'Errore nel login.';
          _accessStatus = false;

        case DiaryAccessResult.tooManyAttempts:
          _error =
              'Troppi tentativi di login effettuati. Si è pregati di riprovare più tardi.';
          _accessStatus = false;
      }
    } catch (e) {
      _accessStatus = false;
      notifyListeners();
      _error = "Errore: $e";
      //return 'Errore nel login: $e';
    } finally {
      notifyListeners();
    }
    String err = _error != null ? _error! : '';
    return err;
  }

  //Termina la sessione
  String logout() {
    final diarySession = DiarySession.session;
    diarySession.endSession();
    notifyListeners();
    return 'Logout effettuato con successo.';
  }
}
