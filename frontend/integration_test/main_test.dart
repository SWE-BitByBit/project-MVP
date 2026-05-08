import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/material_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/material_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/location_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/widget/safe_place_map_widget.dart';

import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';

import 'package:mvp_app_protegge_e_trasforma/data/services/trusted_contact_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';

import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

// --- MOCKS ---
class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeadManRepository extends Mock implements DeadManRepository {}
class MockChatbotService extends Mock implements ChatbotService {}
class MockMaterialService extends Mock implements MaterialService {}
class MockSafePlaceService extends Mock implements SafePlaceService {}
class MockLocationService extends Mock implements LocationService {}

class MockDiaryAccountService extends Mock implements DiaryAccountService {}
class MockNoteService extends Mock implements NoteService {}

class MockTrustedContactService extends Mock implements TrustedContactService {}

class MockJustAudioPlatform extends JustAudioPlatform {
  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    return MockAudioPlayerPlatform(request.id);
  }
  @override
  Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) async {
    return DisposePlayerResponse();
  }
  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(DisposeAllPlayersRequest request) async {
    return DisposeAllPlayersResponse();
  }
}

class MockAudioPlayerPlatform extends AudioPlayerPlatform {
  MockAudioPlayerPlatform(super.id);
  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => const Stream.empty();
  @override
  Future<LoadResponse> load(LoadRequest request) async => LoadResponse(duration: const Duration(seconds: 1));
  @override
  Future<PlayResponse> play(PlayRequest request) async => PlayResponse();
  @override
  Future<PauseResponse> pause(PauseRequest request) async => PauseResponse();
  @override
  Future<SeekResponse> seek(SeekRequest request) async => SeekResponse();
  @override
  Future<SetVolumeResponse> setVolume(SetVolumeRequest request) async => SetVolumeResponse();
  @override
  Future<SetSpeedResponse> setSpeed(SetSpeedRequest request) async => SetSpeedResponse();
  @override
  Future<SetLoopModeResponse> setLoopMode(SetLoopModeRequest request) async => SetLoopModeResponse();
  @override
  Future<SetShuffleModeResponse> setShuffleMode(SetShuffleModeRequest request) async => SetShuffleModeResponse();
  @override
  Future<SetShuffleOrderResponse> setShuffleOrder(SetShuffleOrderRequest request) async => SetShuffleOrderResponse();
}
/// Mock HTTP per evitare errori di rete reali (es. mappe) durante i test
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  app.isIntegrationTest = true;
  HttpOverrides.global = MyHttpOverrides();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Gestione globale degli errori per ignorare fallimenti di rete delle immagini (OpenStreetMap)
  FlutterError.onError = (FlutterErrorDetails details) {
    final bool isImageError = details.exception.toString().contains('image codec') || 
                             details.exception.toString().contains('SocketException') ||
                             details.exception.toString().contains('ClientException');
    if (isImageError) {
      debugPrint('Nota: Errore risorsa immagine ignorato nel test: ${details.exception}');
      return;
    }
    FlutterError.presentError(details);
  };

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    JustAudioPlatform.instance = MockJustAudioPlatform();
    registerFallbackValue(DiaryType.real_diary);
    registerFallbackValue(const DeadManSettings(
      isActive: true,
      firstInactivityTimer: 1,
      secondInactivityTimer: 1,
      messageSubject: '',
      messageBody: '',
    ));
  });

  testWidgets('Suite Completa Test di Integrazione E2E', (tester) async {
    // --- SETUP AMBIENTE ---
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}
    setupLocator();

    final mockAuth = MockAuthRepository();
    final mockDeadMan = MockDeadManRepository();
    final mockChat = MockChatbotService();
    final mockMat = MockMaterialService();
    final mockSafe = MockSafePlaceService();
    final mockLoc = MockLocationService();
    
    final mockDiaryAccountService = MockDiaryAccountService();
    final mockNoteService = MockNoteService();
    final mockTrustedContactService = MockTrustedContactService();

    // Mock Auth & DeadMan (Globali)
    when(() => mockAuth.isLoggedIn()).thenReturn(true);
    when(() => mockAuth.getCurrentUser()).thenReturn(const User(
      sub: 'test', email: 'test@test.com', name: 'Test', surname: 'User', idToken: 'id', accessToken: 'token'
    ));
    when(() => mockAuth.restoreSession()).thenAnswer((_) async => true);
    
    when(() => mockDeadMan.createSettings()).thenAnswer((_) async {});
    when(() => mockDeadMan.sendHeartbeat()).thenAnswer((_) async {});
    when(() => mockDeadMan.saveSettings(any())).thenAnswer((_) async {});
    when(() => mockDeadMan.getSettings()).thenAnswer((_) async => const DeadManSettings(
      isActive: false,
      firstInactivityTimer: 1,
      secondInactivityTimer: 1,
      messageSubject: '',
      messageBody: '',
    ));
    when(() => mockDeadMan.getSettings(forceRefresh: true)).thenAnswer((_) async => const DeadManSettings(
      isActive: false,
      firstInactivityTimer: 1,
      secondInactivityTimer: 1,
      messageSubject: '',
      messageBody: '',
    ));
    when(() => mockDeadMan.getSettings(forceRefresh: false)).thenAnswer((_) async => const DeadManSettings(
      isActive: false,
      firstInactivityTimer: 1,
      secondInactivityTimer: 1,
      messageSubject: '',
      messageBody: '',
    ));
    when(() => mockDeadMan.currentSettings).thenReturn(const DeadManSettings(
      isActive: false,
      firstInactivityTimer: 1,
      secondInactivityTimer: 1,
      messageSubject: '',
      messageBody: '',
    ));

    // Mock Chatbot
    when(() => mockChat.fetchChatPreviews()).thenAnswer((_) async => {'chats': []});
    when(() => mockChat.createChat(any())).thenAnswer((_) async => {
      "chat_id": "c1", "title": "Ciao", "created_at": "2024-01-01", "updated_at": "2024-01-01", "messages": []
    });
    when(() => mockChat.sendMessage("c1", any(), any())).thenAnswer((_) async => {
      "message_id": "m1", "response": "Risposta bot", "title": "Ciao"
    });

    // Mock Materiale
    when(() => mockMat.fetchMaterials()).thenAnswer((_) async => {
      'data': [{'resource_id': '1', 'title': 'Guida', 'content': '...', 'url': '...', 'type': 'article'}]
    });

    // Mock Luoghi Sicuri
    when(() => mockLoc.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockLoc.checkPermission()).thenAnswer((_) async => LocationPermission.always);
    when(() => mockLoc.getCurrentPosition()).thenAnswer((_) async => Position(
      longitude: 11.0, latitude: 46.0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, 
      altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0
    ));
    when(() => mockSafe.fetchSafePlaces()).thenAnswer((_) async => {'data': []});

    // Mock Diario
    when(() => mockDiaryAccountService.checkHasRealPassword()).thenAnswer((_) async => true);
    when(() => mockDiaryAccountService.validateDiaryPassword(any())).thenAnswer((_) async => {
      'access_token': 'mock-session-token',
      'diary_type': 'real_diary'
    });
    when(() => mockNoteService.fetchNotes(any())).thenAnswer((_) async => <Map<String, dynamic>>[
      {
        'note_id': 'note1',
        'title': 'La mia prima nota',
        'content': 'Oggi è una bella giornata.',
        'created_at': DateTime.now().toIso8601String(),
        'last_modified_at': DateTime.now().toIso8601String(),
        'diary_type': 'real_diary'
      }
    ]);

    // Mock Contatti Fidati
    when(() => mockTrustedContactService.getContacts()).thenAnswer((_) async => [
      {
        'id': 'contact1',
        'name': 'Mario Rossi',
        'email': 'mario@example.com',
        'phoneNumber': '1234567890'
      }
    ]);
    when(() => mockTrustedContactService.addContact(any())).thenAnswer((_) async => {
        'id': 'contact2',
        'name': 'Luigi Verdi',
        'email': 'luigi@example.com',
        'phoneNumber': '0987654321'
    });

    // Iniezione Mock
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<AuthRepository>(() => mockAuth);
    getIt.registerLazySingleton<DeadManRepository>(() => mockDeadMan);
    getIt.registerLazySingleton<ChatbotService>(() => mockChat);
    getIt.registerLazySingleton<ChatbotRepository>(() => ChatbotRepository(mockChat));
    getIt.registerLazySingleton<MaterialService>(() => mockMat);
    getIt.registerLazySingleton<MaterialRepository>(() => MaterialRepository(service: mockMat));
    getIt.registerSingleton<LocationService>(mockLoc);
    getIt.registerLazySingleton<SafePlaceService>(() => mockSafe);
    getIt.registerLazySingleton<SafePlaceRepository>(() => SafePlaceRepository(mockSafe));
    
    getIt.registerLazySingleton<DiaryAccountService>(() => mockDiaryAccountService);
    getIt.registerLazySingleton<DiaryAccountRepository>(() => DiaryAccountRepository(mockDiaryAccountService));
    getIt.registerLazySingleton<NoteService>(() => mockNoteService);
    getIt.registerLazySingleton<NoteRepository>(() => NoteRepository(mockNoteService));

    getIt.registerLazySingleton<TrustedContactService>(() => mockTrustedContactService);
    getIt.registerLazySingleton<TrustedContactRepository>(() => TrustedContactRepository(mockTrustedContactService, locationService: mockLoc));

    runApp(const app.MainApp());
    await tester.pumpAndSettle();

    // --- 1. FLOW CHATBOT ---
    debugPrint('Avvio test Chatbot...');
    debugPrint('DEBUG: Tap Chatbot Tab');
    await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
    await tester.pumpAndSettle();
    debugPrint('DEBUG: Verifica Chatbot Schermo');
    expect(find.text('Inizia una conversazione sicura.'), findsOneWidget);

    debugPrint('DEBUG: Enter text Ciao');
    await tester.enterText(find.byType(TextField), 'Ciao');
    await tester.pumpAndSettle();
    debugPrint('DEBUG: Tap Send');
    await tester.tap(find.byIcon(Icons.send_rounded));
    for (int i = 0; i < 5; i++) { await tester.pump(const Duration(milliseconds: 500)); }
    await tester.pumpAndSettle();
    debugPrint('DEBUG: Verifica Risposta Bot');
    expect(find.text('Risposta bot'), findsOneWidget);

    debugPrint('DEBUG: Torna a Home Tab');
    await tester.tap(find.byIcon(Icons.home_outlined).first);
    await tester.pumpAndSettle();

    // --- 2. FLOW MATERIALE ---
    debugPrint('Avvio test Materiale...');
    await tester.tap(find.text('Informazioni').last);
    await tester.pumpAndSettle();
    expect(find.text('Materiale Informativo'), findsWidgets);
    expect(find.text('Guida'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- 3. FLOW LUOGHI SICURI ---
    debugPrint('Avvio test Luoghi Sicuri...');
    await tester.tap(find.text('Luoghi Sicuri').last);
    await tester.pumpAndSettle();
    expect(find.text('Luoghi Sicuri'), findsWidgets);
    expect(find.byType(SafePlaceMapWidget), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- 4. FLOW DIARIO ---
    debugPrint('Avvio test Diario...');
    await tester.tap(find.byIcon(Icons.edit_note_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Accedi al diario'), findsWidgets);
    
    await tester.enterText(find.byType(TextField), 'Password123!');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accedi'));
    
    for (int i = 0; i < 5; i++) { await tester.pump(const Duration(milliseconds: 500)); }
    await tester.pumpAndSettle();
    
    expect(find.text('La mia prima nota'), findsWidgets);
    
    // Torniamo alla Home Tab
    await tester.tap(find.byIcon(Icons.home_outlined).first);
    await tester.pumpAndSettle();

    // --- 5. FLOW CONTATTI FIDATI ---
    debugPrint('Avvio test Contatti Fidati...');
    await tester.tap(find.text('Contatti Fidati').last);
    await tester.pumpAndSettle();
    expect(find.text('Contatti Fidati'), findsWidgets);
    expect(find.text('Mario Rossi'), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome e Cognome'), 'Luigi Verdi');
    await tester.enterText(find.widgetWithText(TextFormField, 'Numero di Cellulare'), '0987654321');
    await tester.enterText(find.widgetWithText(TextFormField, 'Indirizzo Email'), 'luigi@example.com');
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Salva contatto'));
    await tester.pumpAndSettle();
    verify(() => mockTrustedContactService.addContact(any())).called(1);
    
    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- 6. FLOW DEAD MAN SWITCH ---
    debugPrint('Avvio test Dead Man Switch...');
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    expect(find.text('Stato Allarme'), findsOneWidget);
    
    // Attiva lo switch
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.widgetWithText(TextFormField, 'Oggetto Messaggio'), 'Aiuto');
    await tester.enterText(find.widgetWithText(TextFormField, 'Corpo del Messaggio'), 'Sono in pericolo');
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    
    verify(() => mockDeadMan.saveSettings(any())).called(1);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- 7. FLOW AUTH (Logout -> Login) ---
    debugPrint('Avvio test Autenticazione (Logout -> Login placeholder)...');
    when(() => mockAuth.isLoggedIn()).thenReturn(false);
    when(() => mockAuth.getCurrentUser()).thenReturn(null);
    runApp(const app.MainApp());
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();
    
    expect(find.text('Login'), findsWidgets);
    expect(find.text('L\'accesso è consentito solo tramite account Google ufficiale.'), findsOneWidget);
    
    await tester.pageBack();
    await tester.pumpAndSettle();
    
    debugPrint('Test Autenticazione completato.');
    debugPrint('Suite completata con successo!');
  });
}
