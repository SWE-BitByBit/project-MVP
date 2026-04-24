import 'package:get_it/get_it.dart';
import 'app_config.dart';
import 'cache_manager.dart';
import '../data/network/api_client.dart';
import '../data/network/http_api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/safe_place_service.dart';
import '../data/services/location_service.dart';
import '../data/services/trusted_contact_service.dart';
import '../data/services/chatbot_service.dart';

import '../data/repositories/safe_place_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/trusted_contact_repository.dart';
import '../data/repositories/chatbot_repository.dart';


import '../ui/safeplace/view_model/safe_place_view_model.dart';
import '../ui/auth/view_model/auth_view_model.dart';
import '../ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import '../ui/chat/view_model/chatbot_view_model.dart';


final getIt = GetIt.instance;

void setupLocator() {
  // 1. CORE / GLOBAL SERVICES
  _setupCore();

  // 2. MODULO AUTHENTICATION
  _setupAuth();

  // 3. MODULO SAFE PLACES
  _setupSafePlace();

  // 4. MODULO CONTATTI FIDATI (Nuovo)
  _setupTrustedContact();

  // 5. MODULO CHATBOT
  _setupChatbot();
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
  ]));
}

/// Registra le dipendenze relative al modulo dell' autenticazione
void _setupAuth() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthService>()));
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt<AuthRepository>()));
}

/// Registra le dipendenze relative al modulo dei Luoghi Sicuri
void _setupSafePlace() {
  getIt.registerLazySingleton<SafePlaceService>(() => SafePlaceService(baseUrl: AppConfig.apiBaseUrl)); // Refactored to use ApiClient

  getIt.registerLazySingleton<SafePlaceRepository>(() => SafePlaceRepository(getIt<SafePlaceService>()));

  getIt.registerFactory<SafePlaceViewModel>(() => SafePlaceViewModel(
        getIt<SafePlaceRepository>(),
        locationService: getIt<LocationService>(),
      ));
}

/// Registra le dipendenze relative al modulo dei Contatti Fidati.
void _setupTrustedContact() {
  // Service: richiede l'ApiClient per le chiamate REST
  getIt.registerLazySingleton<TrustedContactService>(() => TrustedContactService(apiClient: getIt<ApiClient>()),);

  // Repository: gestisce la logica dei dati e la conversione DTO
  getIt.registerLazySingleton<TrustedContactRepository>(() => TrustedContactRepository(getIt<TrustedContactService>()),);

  // ViewModel: iniettiamo sia il repo dei contatti che quello auth (per dati utente)
  // Usiamo registerFactory per avere uno stato pulito ogni volta che si apre la schermata
  getIt.registerFactory<TrustedContactViewModel>(() => TrustedContactViewModel(
      getIt<TrustedContactRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}

/// Registra le dipendenze relative al modulo del Chatbot
void _setupChatbot() {
  // Registriamo il Service passando l'ApiClient già presente nel locator
  getIt.registerLazySingleton<ChatbotService>(() => ChatbotService(apiClient: getIt<ApiClient>()));

  getIt.registerLazySingleton<ChatbotRepository>(() => ChatbotRepository(getIt<ChatbotService>()),);

  getIt.registerFactory<ChatbotViewModel>(() => ChatbotViewModel(
    getIt<ChatbotRepository>(),
    authRepository: getIt<AuthRepository>(),
  ),
  );
}