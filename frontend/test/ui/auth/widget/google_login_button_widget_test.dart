import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/google_login_button_widget.dart';

void main() {
  group('GoogleLoginButtonWidget Widget Test', () {
    testWidgets('Deve mostrare CircularProgressIndicator quando isLoading è true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButtonWidget(
              onPressedCallback: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('Deve mostrare il pulsante quando isLoading è false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButtonWidget(
              onPressedCallback: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Accedi con Google'), findsOneWidget);
    });

    testWidgets('Deve chiamare onPressedCallback al click', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleLoginButtonWidget(
              onPressedCallback: () => pressed = true,
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      expect(pressed, isTrue);
    });
  });
}
