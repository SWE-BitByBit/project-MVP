import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/auth_placeholder_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('AuthPlaceholderScreen', () {
    testWidgets('Renderizza correttamente tutti i parametri visivi forniti', (tester) async {
      const testTitle = 'Titolo di Test';
      const testMessage = 'Messaggio esplicativo di test.';
      const testIcon = Icons.security;
      final testAppBar = AppBar(title: const Text('AppBar di Test'));

      await tester.pumpWidget(
        MaterialApp(
          home: AuthPlaceholderScreen(
            appBar: testAppBar,
            title: testTitle,
            message: testMessage,
            icon: testIcon,
          ),
        ),
      );

      // Verifica AppBar
      expect(find.text('AppBar di Test'), findsOneWidget);

      // Verifica testi principali
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);

      // Verifica Icona custom
      expect(find.byIcon(testIcon), findsOneWidget);

      // Verifica bottone
      expect(find.text('Accedi ora'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('Effettua la navigazione verso /login al tap sul bottone', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          routes: {
            '/login': (context) => const Scaffold(body: Text('Fake Login Screen')),
          },
          home: AuthPlaceholderScreen(
            appBar: AppBar(title: const Text('AppBar')),
            title: 'Title',
            message: 'Message',
            icon: Icons.lock,
          ),
        ),
      );

      // Tappiamo sul bottone "Accedi ora"
      await tester.tap(find.text('Accedi ora'));
      await tester.pumpAndSettle(); // Aspettiamo che la navigazione sia completata

      // Verifichiamo che la rotta sia stata pusata
      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));

      // Verifichiamo che a schermo ci sia la nuova UI mockata
      expect(find.text('Fake Login Screen'), findsOneWidget);
    });
  });
}