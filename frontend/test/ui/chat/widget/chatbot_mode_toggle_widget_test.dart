import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_mode_toggle_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';


void main() {
  late MockChatbotViewModel mockViewModel;

  setUpAll(() {
    registerFallbackValue(ChatMode.mirror);
  });

  setUp(() {
    mockViewModel = MockChatbotViewModel();
    // Setup di default per la chiamata setMode
    when(() => mockViewModel.setMode(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChangeNotifierProvider<ChatbotViewModel>.value(
            value: mockViewModel,
            child: const ChatbotModeToggleWidget(),
          ),
        ),
      ),
    );
  }

  group('ChatbotModeToggleWidget', () {
    testWidgets('Mostra l\'icona Mirror quando la modalità corrente è ChatMode.mirror', (tester) async {
      when(() => mockViewModel.mode).thenReturn(ChatMode.mirror);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.auto_awesome_motion), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsNothing);
    });

    testWidgets('Mostra l\'icona Detective quando la modalità corrente è ChatMode.detective', (tester) async {
      when(() => mockViewModel.mode).thenReturn(ChatMode.detective);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_motion), findsNothing);
    });

    testWidgets('Apre il menu a tendina e chiama setMode quando si seleziona una modalità', (tester) async {
      when(() => mockViewModel.mode).thenReturn(ChatMode.mirror);

      await tester.pumpWidget(createWidgetUnderTest());

      // 1. Tocca il widget per aprire il popup menu
      await tester.tap(find.byType(PopupMenuButton<ChatMode>));
      await tester.pumpAndSettle();

      // 2. Verifica che le opzioni del menu siano visibili
      expect(find.text('Specchio intelligente'), findsOneWidget);
      expect(find.text('Detective delle relazioni'), findsOneWidget);

      // 3. Seleziona la modalità Detective dal menu
      await tester.tap(find.text('Detective delle relazioni'));
      await tester.pumpAndSettle();

      // 4. Verifica che il ViewModel sia stato aggiornato con la nuova modalità
      verify(() => mockViewModel.setMode(ChatMode.detective)).called(1);
    });
  });
}