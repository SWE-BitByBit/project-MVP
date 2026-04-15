import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/widget/header_widget.dart';

void main() {
  group('HeaderWidget Widget Test', () {
    testWidgets('Deve renderizzare l\'icona e il testo correttamente', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeaderWidget(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Accedi al tuo account'), findsOneWidget);
    });

    testWidgets('Deve avere lo stile del testo corretto', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeaderWidget(),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Accedi al tuo account'));
      expect(textWidget.style?.fontSize, 22);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
