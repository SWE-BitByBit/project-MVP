import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeadManRepository extends Mock implements DeadManRepository {}
class MockChatbotService extends Mock implements ChatbotService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockDeadManRepository mockDeadManRepository;
  late MockChatbotService mockChatbotService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockDeadManRepository = MockDeadManRepository();
    mockChatbotService = MockChatbotService();

    // Mock Auth
    final testUser = User(
      sub: 'test-id',
      email: 'test@example.com',
      name: 'Test',
      surname: 'User',
      idToken: 'id',
      accessToken: 'access',
    );
    when(() => mockAuthRepository.isLoggedIn()).thenReturn(true);
    when(() => mockAuthRepository.getCurrentUser()).thenReturn(testUser);
    when(() => mockAuthRepository.restoreSession()).thenAnswer((_) async => true);

    // Mock DeadMan
    when(() => mockDeadManRepository.createSettings()).thenAnswer((_) async {});
    when(() => mockDeadManRepository.sendHeartbeat()).thenAnswer((_) async {});
    when(() => mockDeadManRepository.currentSettings).thenReturn(null);

    // Mock Chatbot
    when(() => mockChatbotService.fetchChatPreviews()).thenAnswer((_) async => {'chats': []});
    
    // Configura il fallback per l'argomento mocktail se necessario, ma any() di string va bene
    when(() => mockChatbotService.createChat(any())).thenAnswer((_) async => {
      "chat_id": "real_chat_1",
      "title": "Ciao",
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String(),
      "messages": []
    });

    when(() => mockChatbotService.sendMessage("real_chat_1", any(), any())).thenAnswer((_) async => {
      "message_id": "bot_msg_1",
      "response": "Sono il tuo assistente virtuale. Come posso aiutarti?",
      "title": "Ciao"
    });
  });

  testWidgets('Test di integrazione End-to-End: Chatbot creazione e ricezione messaggio', (WidgetTester tester) async {
    // 1. Inizializza l'ambiente reale (senza far partire runApp dentro main se possibile, o sovrascrivendo subito)
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}
    
    setupLocator();
    
    // 2. Inietta i mock PRIMA che l'app parta o subito dopo
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    getIt.registerLazySingleton<DeadManRepository>(() => mockDeadManRepository);
    getIt.registerLazySingleton<ChatbotService>(() => mockChatbotService);
    getIt.registerLazySingleton<ChatbotRepository>(() => ChatbotRepository(mockChatbotService));

    // 3. Avvia l'app
    runApp(const app.MainApp());
    await tester.pumpAndSettle();

    // 4. Naviga alla schermata Chatbot (Tab 0)
    // Cerchiamo la destinazione nella NavigationBar
    final chatbotTab = find.byIcon(Icons.chat_bubble_outline);
    expect(chatbotTab, findsWidgets);
    
    await tester.tap(chatbotTab.first);
    await tester.pumpAndSettle();

    // Verifica che siamo nella schermata del chatbot
    expect(find.text('Assistente AI'), findsWidgets); // Titolo AppBar
    expect(find.text('Inizia una conversazione sicura.'), findsOneWidget);

    // 5. Invia un messaggio
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Ciao');
    await tester.pumpAndSettle();

    final sendButton = find.byIcon(Icons.send_rounded);
    expect(sendButton, findsOneWidget);
    
    await tester.tap(sendButton);
    
    // Attendiamo che il mock risponda (usiamo pump ripetuti per simulare il tempo di rete)
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();

    // 6. Verifica che il messaggio utente e la risposta del bot siano comparsi a schermo
    expect(find.text('Ciao'), findsOneWidget);
    expect(find.text('Sono il tuo assistente virtuale. Come posso aiutarti?'), findsOneWidget);

    verify(() => mockChatbotService.createChat(any())).called(1);
    verify(() => mockChatbotService.sendMessage("real_chat_1", 'Ciao', 'MIRROR')).called(1);
  });
}
