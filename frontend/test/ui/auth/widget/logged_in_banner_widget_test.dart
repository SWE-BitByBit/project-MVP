import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/logged_in_banner_widget.dart';

void main() {
  group('LoggedInBannerWidget Widget Test', () {
    testWidgets('Deve mostrare l\'email corretta e l\'icona di successo', (WidgetTester tester) async {
      const testEmail = 'user@example.com';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoggedInBannerWidget(email: testEmail),
          ),
        ),
      );

      expect(find.text(testEmail), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('Sei autenticato con l\'indirizzo:'), findsOneWidget);
    });
  });
}
