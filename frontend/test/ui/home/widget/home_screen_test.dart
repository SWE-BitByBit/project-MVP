import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';

// Import dei Mock (Assicurati che esistano o creali come mostrato sotto)
import '../../../../testing/mocks/auth/mock_auth_view_model.dart';
import '../../../../testing/mocks/home/mock_home_view_model.dart';
import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';
import '../../../../testing/mocks/diary/mock_diary_view_model.dart';

// Mock rapido per Chatbot se non lo hai
class MockChatbotViewModel extends Mock implements ChatbotViewModel {}

void main() {
  late MockAuthViewModel mockAuthVm;
  late MockHomeViewModel mockHomeVm;
  late MockDiaryAccessViewModel mockDiaryAccessVm;
  late MockDiaryViewModel mockDiaryVm;
  late MockChatbotViewModel mockChatbotVm;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    mockAuthVm = MockAuthViewModel();
    mockHomeVm = MockHomeViewModel();
    mockDiaryAccessVm = MockDiaryAccessViewModel();
    mockDiaryVm = MockDiaryViewModel();
    mockChatbotVm = MockChatbotViewModel();

    final sl = GetIt.instance;
    sl.reset(); // Pulizia totale per evitare conflitti tra test

    // Registrazione in GetIt (necessaria per i widget che non usano Provider)
    sl.registerSingleton<HomeViewModel>(mockHomeVm);
    sl.registerSingleton<ChatbotViewModel>(mockChatbotVm);
    sl.registerSingleton<DiaryAccessViewModel>(mockDiaryAccessVm);
    sl.registerSingleton<DiaryViewModel>(mockDiaryVm);

    // Stubbing minimi per evitare crash durante il build dei figli
    _stubViewModel(mockHomeVm, mockAuthVm, mockDiaryAccessVm, mockDiaryVm, mockChatbotVm);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthVm),
        ChangeNotifierProvider<DiaryAccessViewModel>.value(value: mockDiaryAccessVm),
        ChangeNotifierProvider<DiaryViewModel>.value(value: mockDiaryVm),
        ChangeNotifierProvider<ChatbotViewModel>.value(value: mockChatbotVm),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen - Success Tests', () {
    testWidgets('mostra la HomeTabView come tab iniziale', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Protegge e Trasforma'), findsOneWidget); // Titolo della HomeTabView
      expect(find.byIcon(Icons.home), findsWidgets); // Icona selezionata nella NavBar
    });

    testWidgets('naviga tra le tab correttamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vai al Diario
      await tester.tap(find.text('Diario'));
      await tester.pumpAndSettle();

      expect(find.text('Diario protetto'), findsOneWidget); // Placeholder se non loggato
    });


  });
}

/// Funzione di utilità per evitare che i build dei figli falliscano
void _stubViewModel(MockHomeViewModel h, MockAuthViewModel a, MockDiaryAccessViewModel da, MockDiaryViewModel d, MockChatbotViewModel c) {
  // Auth
  when(() => a.isInitializing).thenReturn(false);
  when(() => a.currentUser).thenReturn(null);

  // Home
  final mockCommand = MockCommandDashboard();
  when(() => mockCommand.isRunning).thenReturn(ValueNotifier(false));
  when(() => mockCommand.errors).thenReturn(ValueNotifier(null));
  when(() => mockCommand.value).thenReturn([]);
  when(() => h.loadDashboard).thenReturn(mockCommand);

  // Diary Access
  final mockLoginCmd = MockCommand<String, void>();
  when(() => mockLoginCmd.isRunning).thenReturn(ValueNotifier(false));
  when(() => mockLoginCmd.canRun).thenReturn(ValueNotifier(true));
  when(() => da.login).thenReturn(mockLoginCmd);
  when(() => da.asyncError).thenReturn(ValueNotifier(null));

}