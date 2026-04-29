import 'package:flutter/widgets.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';

/// ViewModel che gestisce l'accesso alla funzionalità dei diari e le impostazioni di sicurezza.
class DiaryAccessViewModel extends ChangeNotifier {
  final DiaryAccountRepository _accRepo;

  // ==========================================
  // --- STATO DELLA UI (ACCESSO) ---
  // ==========================================
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Usati per schermata di caricamento iniziale e setup
  bool isCheckingStatus = true;
  bool needsInitialSetup = false;

  final ValueNotifier<String?> asyncError = ValueNotifier(null);

  // ==========================================
  // --- STATO DELLA UI (MODIFICA PASSWORD) ---
  // ==========================================
  String _passwordError = "";
  String get passwordError => _passwordError;

  bool _setupSuccess = false;
  bool get setupSuccess => _setupSuccess;

  // ==========================================
  // --- COMANDI REATTIVI ---
  // ==========================================
  late final Command<String, void> login;
  late final Command<void, void> logout;
  late final Command<String, void> createInitialPassword; // Per la prima attivazione

  DiaryAccessViewModel(this._accRepo) {
    login = Command.createAsync<String, void>(_login, initialValue: null);
    logout = Command.createAsyncNoParamNoResult(_logout);
    createInitialPassword = Command.createAsync<String, void>(_createInitialPassword, initialValue: null);

    _init(); // Sostituisce la chiamata diretta per gestire caricamento e setup iniziale
  }

  /// Verifica se esiste un token o se è il primissimo avvio
  Future<void> _init() async {
    isCheckingStatus = true;
    notifyListeners();

    if (DiarySession.session.isDiaryAuth == true) {
      _isAuthenticated = true;
    } else {
      // 1. Controlla prima se c'è una sessione salvata
      final hasSession = await DiarySession.session.restoreSession();
      if (hasSession) {
        _isAuthenticated = true;
      } else {
        // 2. Se non c'è sessione, interroga il backend: l'utente ha mai creato la password?
        try {
          needsInitialSetup = !(await _accRepo.checkHasRealPassword());
        } catch (e) {
          needsInitialSetup = false; // Fallback sicuro
        }
      }
    }

    isCheckingStatus = false;
    notifyListeners();
  }

  // ==========================================
  // --- IMPLEMENTAZIONE LOGIN / LOGOUT (ORIGINALI) ---
  // ==========================================

  Future<void> _login(String pwd) async {
    asyncError.value = null;

    final res = await _accRepo.clarifyAccessResult(pwd);

    switch (res) {
      case DiaryAccessResult.real_diary:
      case DiaryAccessResult.fake_diary:
        _isAuthenticated = true;
        break;
      case DiaryAccessResult.too_many_attempts:
        asyncError.value = 'Troppi tentativi effettuati. Riprova più tardi.';
        break;
      case DiaryAccessResult.error:
      default:
          asyncError.value = 'Password errata o errore di connessione.';
          break;
    }

    notifyListeners();
  }

  Future<void> _logout() async {
    await DiarySession.session.endSession();
    _isAuthenticated = false;
    notifyListeners();
  }

  // ==========================================
  // --- LOGICA PASSWORD (PRIMA ATTIVAZIONE E MODIFICA) ---
  // ==========================================

  /// Crea la password per la prima volta (nessuna vecchia password)
  Future<void> _createInitialPassword(String newPassword) async {
    _passwordError = _validatePasswordLocally(newPassword);
    if (_passwordError.isNotEmpty) {
      notifyListeners();
      throw Exception("Password non valida");
    }
    final serverError = await _accRepo.setPassword(
      oldPassword: null,
      newPassword: newPassword,
      diaryType: DiaryType.real_diary,
    );

    if (serverError.isNotEmpty) {
      _passwordError = serverError;
      notifyListeners();
      throw Exception(serverError);
    }

    needsInitialSetup = false;
    await _login(newPassword);
  }

  /// Aggiorna la password del diario REALE dal menu impostazioni
  Future<void> updateRealPassword(String oldPwd, String newPwd) async {
    _passwordError = _validatePasswordLocally(newPwd);
    if (_passwordError.isNotEmpty) {
      notifyListeners();
      return;
    }

    final error = await _accRepo.setPassword(
      oldPassword: oldPwd,
      newPassword: newPwd,
      diaryType: DiaryType.real_diary,
    );

    if (error.isEmpty) {
      _setupSuccess = true;
    } else {
      _passwordError = error;
    }
    notifyListeners();
  }

  /// Imposta o aggiorna la password FITTIZIA
  Future<void> submitFakePassword(String realPwd, String fakePwd) async {
    _passwordError = _validatePasswordLocally(fakePwd);
    if (_passwordError.isNotEmpty) {
      notifyListeners();
      return;
    }

    final error = await _accRepo.setPassword(
      oldPassword: realPwd,
      newPassword: fakePwd,
      diaryType: DiaryType.fake_diary,
    );

    if (error.isEmpty) {
      _setupSuccess = true;
    } else {
      _passwordError = error;
    }
    notifyListeners();
  }

  // ==========================================
  // --- HELPERS E VALIDAZIONE ---
  // ==========================================

  void resetFormState() {
    _passwordError = "";
    _setupSuccess = false;
    notifyListeners();
  }

  void validateInput(String pwd) {
    _passwordError = _validatePasswordLocally(pwd);
    notifyListeners();
  }

  String _validatePasswordLocally(String pwd) {
    String error = "";
    if (pwd.length < 10) return "Minimo 10 caratteri.\n"; // Ritorno rapido
    if (!pwd.contains(RegExp(r"[A-Z]")) || !pwd.contains(RegExp(r"[a-z]"))) error += "Deve contenere maiuscole e minuscole.\n";
    if (!pwd.contains(RegExp(r"[0-9]"))) error += "Deve contenere almeno un numero.\n";
    if (!pwd.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) error += "Deve contenere un carattere speciale.\n";
    if (pwd.contains(RegExp(r"\s"))) error += "Non può contenere spazi.\n";
    return error.trim();
  }

  @override
  void dispose() {
    login.dispose();
    logout.dispose();
    createInitialPassword.dispose();
    super.dispose();
  }
}