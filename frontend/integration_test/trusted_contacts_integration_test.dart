import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/trusted_contact_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/location_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeadManRepository extends Mock implements DeadManRepository {}
class MockTrustedContactService extends Mock implements TrustedContactService {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  app.isIntegrationTest = true;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockDeadManRepository mockDeadManRepository;
  late MockTrustedContactService mockTrustedContactService;
  late MockLocationService mockLocationService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockDeadManRepository = MockDeadManRepository();
    mockTrustedContactService = MockTrustedContactService();
    mockLocationService = MockLocationService();

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

    // Mock Trusted Contacts
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
  });

  testWidgets('Test di integrazione End-to-End: Contatti Fidati', (WidgetTester tester) async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}
    
    setupLocator();
    
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    getIt.registerLazySingleton<DeadManRepository>(() => mockDeadManRepository);
    getIt.registerLazySingleton<LocationService>(() => mockLocationService);
    getIt.registerLazySingleton<TrustedContactService>(() => mockTrustedContactService);
    getIt.registerLazySingleton<TrustedContactRepository>(() => TrustedContactRepository(mockTrustedContactService, locationService: mockLocationService));

    runApp(const app.MainApp());
    await tester.pumpAndSettle();

    // 1. Naviga alla schermata Contatti Fidati dalla Home
    final contattiCard = find.text('Contatti Fidati');
    expect(contattiCard, findsWidgets);
    
    await tester.tap(contattiCard.last);
    await tester.pumpAndSettle();

    // 2. Verifica che i contatti vengano mostrati
    expect(find.text('Contatti Fidati'), findsWidgets);
    expect(find.text('Mario Rossi'), findsOneWidget);

    // 3. Aggiungi un nuovo contatto
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);
    
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Compila il form
    final nameField = find.widgetWithText(TextFormField, 'Nome e Cognome');
    final phoneField = find.widgetWithText(TextFormField, 'Numero di Cellulare');
    final emailField = find.widgetWithText(TextFormField, 'Indirizzo Email');
    
    await tester.enterText(nameField, 'Luigi Verdi');
    await tester.enterText(phoneField, '0987654321');
    await tester.enterText(emailField, 'luigi@example.com');
    await tester.pumpAndSettle();

    final saveButton = find.text('Salva contatto');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(() => mockTrustedContactService.addContact(any())).called(1);
  });
}
