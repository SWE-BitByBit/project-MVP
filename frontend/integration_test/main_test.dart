import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

// --- MOCKS ---
class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeadManRepository extends Mock implements DeadManRepository {}
class MockChatbotService extends Mock implements ChatbotService {}
class MockMaterialService extends Mock implements MaterialService {}
class MockSafePlaceService extends Mock implements SafePlaceService {}
class MockLocationService extends Mock implements LocationService {}

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

  testWidgets('Suite Completa Test di Integrazione E2E: Chatbot, Materiale e Luoghi Sicuri', (tester) async {
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

    // Mock Auth & DeadMan (Globali)
    when(() => mockAuth.isLoggedIn()).thenReturn(true);
    when(() => mockAuth.getCurrentUser()).thenReturn(const User(
      sub: 'test', email: 'test@test.com', name: 'Test', surname: 'User', idToken: 'id', accessToken: 'token'
    ));
    when(() => mockAuth.restoreSession()).thenAnswer((_) async => true);
    when(() => mockDeadMan.createSettings()).thenAnswer((_) async {});
    when(() => mockDeadMan.sendHeartbeat()).thenAnswer((_) async {});
    when(() => mockDeadMan.currentSettings).thenReturn(null);

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

    runApp(const app.MainApp());
    await tester.pumpAndSettle();

    // --- 1. FLOW CHATBOT ---
    print('Avvio test Chatbot...');
    print('DEBUG: Tap Chatbot Tab');
    await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
    await tester.pumpAndSettle();
    print('DEBUG: Verifica Chatbot Schermo');
    expect(find.text('Inizia una conversazione sicura.'), findsOneWidget);

    print('DEBUG: Enter text Ciao');
    await tester.enterText(find.byType(TextField), 'Ciao');
    await tester.pumpAndSettle();
    print('DEBUG: Tap Send');
    await tester.tap(find.byIcon(Icons.send_rounded));
    for (int i = 0; i < 5; i++) { await tester.pump(const Duration(milliseconds: 500)); }
    await tester.pumpAndSettle();
    print('DEBUG: Verifica Risposta Bot');
    expect(find.text('Risposta bot'), findsOneWidget);

    print('DEBUG: Torna a Home Tab');
    // Torniamo alla Home Tab (Tab 1) per vedere le card
    await tester.tap(find.byIcon(Icons.home_outlined).first);
    await tester.pumpAndSettle();

    // --- 2. FLOW MATERIALE ---
    print('Avvio test Materiale...');
    print('DEBUG: Tap Informazioni');
    await tester.tap(find.text('Informazioni').last);
    await tester.pumpAndSettle();
    print('DEBUG: Verifica Materiale Informativo');
    expect(find.text('Materiale Informativo'), findsWidgets);
    expect(find.text('Guida'), findsOneWidget);
    
    print('DEBUG: PageBack Materiale');
    // Torniamo indietro alla Home Dashboard
    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- 3. FLOW LUOGHI SICURI ---
    print('Avvio test Luoghi Sicuri...');
    print('DEBUG: Tap Luoghi Sicuri');
    await tester.tap(find.text('Luoghi Sicuri').last);
    await tester.pumpAndSettle();
    print('DEBUG: Verifica Luoghi Sicuri');
    expect(find.text('Luoghi Sicuri'), findsWidgets);
    expect(find.byType(SafePlaceMapWidget), findsOneWidget);
    
    print('DEBUG: PageBack Luoghi Sicuri');
    await tester.pageBack();
    await tester.pumpAndSettle();

    print('Suite completata con successo!');
  });
}


