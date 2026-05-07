import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeadManRepository extends Mock implements DeadManRepository {}
class MockDiaryAccountService extends Mock implements DiaryAccountService {}
class MockNoteService extends Mock implements NoteService {}

void main() {
  app.isIntegrationTest = true;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockDeadManRepository mockDeadManRepository;
  late MockDiaryAccountService mockDiaryAccountService;
  late MockNoteService mockNoteService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockDeadManRepository = MockDeadManRepository();
    mockDiaryAccountService = MockDiaryAccountService();
    mockNoteService = MockNoteService();

    registerFallbackValue(DiaryType.real_diary);

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

    // Mock Diary Account
    when(() => mockDiaryAccountService.checkHasRealPassword()).thenAnswer((_) async => true);
    
    // Per gestire clarifyAccessResult, mockiamo sia validateDiaryPassword che i check interni
    when(() => mockDiaryAccountService.validateDiaryPassword(any())).thenAnswer((_) async => {
      'access_token': 'mock-session-token',
      'diary_type': 'real_diary'
    });

    // Mock Note Service
    when(() => mockNoteService.fetchNotes(any())).thenAnswer((_) async => [
      {
        'id': 'note1',
        'title': 'La mia prima nota',
        'content': 'Oggi è una bella giornata.',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'diary_type': 'real_diary'
      }
    ]);
  });

  testWidgets('Test di integrazione End-to-End: Accesso Diario e visualizzazione note', (WidgetTester tester) async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}
    
    setupLocator();
    
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    getIt.registerLazySingleton<DeadManRepository>(() => mockDeadManRepository);
    getIt.registerLazySingleton<DiaryAccountService>(() => mockDiaryAccountService);
    getIt.registerLazySingleton<DiaryAccountRepository>(() => DiaryAccountRepository(mockDiaryAccountService));
    getIt.registerLazySingleton<NoteService>(() => mockNoteService);
    getIt.registerLazySingleton<NoteRepository>(() => NoteRepository(mockNoteService));

    runApp(const app.MainApp());
    await tester.pumpAndSettle();

    // 1. Naviga alla schermata Diario (Tab 2)
    final diaryTab = find.byIcon(Icons.edit_note_outlined);
    expect(diaryTab, findsWidgets);
    
    await tester.tap(diaryTab.first);
    await tester.pumpAndSettle();

    // 2. Verifica che siamo nella schermata di accesso
    expect(find.text('Accedi al diario'), findsWidgets);

    // 3. Inserisci la password e fai login
    final passwordField = find.byType(TextField);
    expect(passwordField, findsOneWidget);
    
    await tester.enterText(passwordField, 'Password123!');
    await tester.pumpAndSettle();

    final loginButton = find.text('Accedi');
    expect(loginButton, findsOneWidget);
    
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 4. Verifica che le note siano visualizzate
    expect(find.text('La mia prima nota'), findsWidgets);
    

    verify(() => mockDiaryAccountService.validateDiaryPassword('Password123!')).called(1);
    verify(() => mockNoteService.fetchNotes(any())).called(greaterThanOrEqualTo(1));
  });
}
