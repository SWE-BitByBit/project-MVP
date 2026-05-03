import 'package:get_it/get_it.dart';
import 'app_config.dart';
import 'cache_manager.dart';

// --- NETWORK ---
import '../data/network/api_client.dart';
import '../data/network/http_api_client.dart';

// --- SERVICES ---
import '../data/services/auth_service.dart';
import '../data/services/safe_place_service.dart';
import '../data/services/location_service.dart';
import '../data/services/trusted_contact_service.dart';
import '../data/services/chatbot_service.dart';
import '../data/services/material_service.dart';
import '../data/services/dead_man_service.dart';
import '../data/services/diary_account_service.dart';
import '../data/services/note_service.dart';

// --- REPOSITORIES ---
import '../data/repositories/safe_place_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/trusted_contact_repository.dart';
import '../data/repositories/chatbot_repository.dart';
import '../data/repositories/material_repository.dart';
import '../data/repositories/dead_man_repository.dart';
import '../data/repositories/diary_account_repository.dart';
import '../data/repositories/note_repository.dart';

// --- VIEW MODELS ---
import '../ui/safeplace/view_model/safe_place_view_model.dart';
import '../ui/auth/view_model/auth_view_model.dart';
import '../ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import '../ui/chat/view_model/chatbot_view_model.dart';
import '../ui/material/view_model/material_view_model.dart';
import '../ui/settings/view_model/dead_man_view_model.dart';
import '../ui/sos/view_model/sos_view_model.dart';
import '../ui/home/view_model/home_view_model.dart';
import '../ui/diary/view_model/diary_access_view_model.dart';
import '../ui/diary/view_model/diary_view_model.dart';


final getIt = GetIt.instance;

void setupLocator() {
  // 1. CORE / GLOBAL SERVICES
  _setupCore();

  _setupHome();

  // 2. MODULO AUTHENTICATION
  _setupAuth();

  // 3. MODULO SAFE PLACES
  _setupSafePlace();

  // 4. MODULO CONTATTI FIDATI
  _setupTrustedContact();

  // 5. MODULO CHATBOT
  _setupChatbot();

  // 6. MODULO MATERIALE INFORMATIVO
  _setupMaterial();

  // 7. MODULO ALLARME AUTOMATICO
  _setupSettings();

  // 8. MODULO DIARIO CRIPTATO E FITTIZIO
  _setupDiary();
}

void _setupCore() {
  getIt.registerSingleton<LocationService>(LocationService());

  getIt.registerSingleton<ApiClient>(
    HttpApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      getToken: () async {
        if (getIt.isRegistered<AuthRepository>()) {
          return getIt<AuthRepository>().getCurrentUser()?.accessToken;
        }
        return null;
      },
    ),
  );

  getIt.registerLazySingleton<CacheManager>(() => CacheManager([
    getIt<TrustedContactRepository>(),
    getIt<ChatbotRepository>(),
    getIt<SafePlaceRepository>(),
    getIt<MaterialRepository>(),
    getIt<DeadManRepository>(),
    getIt<NoteRepository>(),
  ]));
}

void _setupHome() {
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel(getIt<DeadManRepository>()));
}

/// Registra le dipendenze relative al modulo dell' autenticazione
void _setupAuth() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthService>()));
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt<AuthRepository>()));
}

/// Registra le dipendenze relative al modulo dei Luoghi Sicuri
void _setupSafePlace() {
  getIt.registerLazySingleton<SafePlaceService>(() => SafePlaceService(apiClient: getIt<ApiClient>()));

  getIt.registerLazySingleton<SafePlaceRepository>(() => SafePlaceRepository(getIt<SafePlaceService>()));

  getIt.registerFactory<SafePlaceViewModel>(() => SafePlaceViewModel(
    getIt<SafePlaceRepository>(),
    locationService: getIt<LocationService>(),
  ));
}

/// Registra le dipendenze relative al modulo dei Contatti Fidati
void _setupTrustedContact() {
  //-----------------MOCKED----------------
  getIt.registerLazySingleton<TrustedContactService>(() => TrustedContactService(apiClient: getIt<ApiClient>()));
  //getIt.registerLazySingleton<TrustedContactService>(() => MockTrustedContactService());

  getIt.registerLazySingleton<TrustedContactRepository>(() => TrustedContactRepository(getIt<TrustedContactService>()));

  getIt.registerFactory<TrustedContactViewModel>(() => TrustedContactViewModel(
    getIt<TrustedContactRepository>(),
    authRepository: getIt<AuthRepository>(),
  ));

  getIt.registerFactory<SosViewModel>(() => SosViewModel(
    contactsRepository: getIt<TrustedContactRepository>(),
    authRepository: getIt<AuthRepository>(),
  ));
}

/// Registra le dipendenze relative al modulo del Chatbot
void _setupChatbot() {
  getIt.registerLazySingleton<ChatbotService>(() => ChatbotService(apiClient: getIt<ApiClient>()));

  getIt.registerLazySingleton<ChatbotRepository>(() => ChatbotRepository(getIt<ChatbotService>()));

  getIt.registerFactory<ChatbotViewModel>(() => ChatbotViewModel(
    getIt<ChatbotRepository>(),
    authRepository: getIt<AuthRepository>(),
  ));
}

/// Registra le dipendenze relative al modulo del Materiale Informativo
void _setupMaterial() {
  getIt.registerLazySingleton<MaterialService>(() => MaterialService(apiClient: getIt<ApiClient>()));

  getIt.registerLazySingleton<MaterialRepository>(() => MaterialRepository(service: getIt<MaterialService>()));

  getIt.registerFactory<MaterialViewModel>(() => MaterialViewModel(getIt<MaterialRepository>()));
}

/// Registra le dipendenze relative al modulo dell'allarme automatico
void _setupSettings() {
  //-----------------MOCKED----------------
  getIt.registerLazySingleton<DeadManService>(() => DeadManService(apiClient: getIt<ApiClient>()));
  //getIt.registerLazySingleton<DeadManService>(() => MockDeadManService());

  getIt.registerLazySingleton<DeadManRepository>(() => DeadManRepository(getIt<DeadManService>()));

  getIt.registerFactory<DeadManViewModel>(() => DeadManViewModel(getIt<DeadManRepository>(), authRepository: getIt<AuthRepository>()));
}

/// Registra le dipendenze relative al modulo del Diario (Criptato e Fittizio)
void _setupDiary() {

  // Services
  //-----------------MOCKED----------------

  getIt.registerLazySingleton<DiaryAccountService>(() => DiaryAccountService(apiClient: getIt<ApiClient>()));
  getIt.registerLazySingleton<NoteService>(() => NoteService(apiClient: getIt<ApiClient>()));
/*
  getIt.registerLazySingleton<DiaryAccountService>(() => MockDiaryAccountService());
  getIt.registerLazySingleton<NoteService>(() => MockNoteService());
*/

  // Repositories
  getIt.registerLazySingleton<DiaryAccountRepository>(() => DiaryAccountRepository(getIt<DiaryAccountService>()));
  getIt.registerLazySingleton<NoteRepository>(() => NoteRepository(getIt<NoteService>()));

  // ViewModels (Registrati come Factory per garantire uno stato pulito alla riapertura delle schermate)
  getIt.registerFactory<DiaryAccessViewModel>(() => DiaryAccessViewModel(getIt<DiaryAccountRepository>()));
  getIt.registerFactory<DiaryViewModel>(() => DiaryViewModel(getIt<NoteRepository>(), getIt<DiaryAccountRepository>()));
}