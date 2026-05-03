import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_mode_info_dialog_widget.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const ChatbotModeInfoDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('ChatbotModeInfoDialog', () {
    testWidgets('Mostra correttamente i testi e le icone statiche', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Apri il dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verifica i testi principali
      expect(find.text('Modalità Chatbot'), findsOneWidget);
      expect(find.text('Specchio intelligente'), findsOneWidget);
      expect(find.text('Detective delle relazioni'), findsOneWidget);
      expect(find.text('Ho capito'), findsOneWidget);

      // Verifica icone
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_motion), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('Si chiude quando viene premuto il bottone "Ho capito"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Apri il dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatbotModeInfoDialog), findsOneWidget);

      // Premi il bottone "Ho capito"
      await tester.tap(find.text('Ho capito'));
      await tester.pumpAndSettle();

      // Verifica che il dialog sia chiuso e rimosso dall'albero
      expect(find.byType(ChatbotModeInfoDialog), findsNothing);
    });
  });
}