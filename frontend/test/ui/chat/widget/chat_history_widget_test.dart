import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sostituisci i percorsi con quelli del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_history_widget.dart'; // Nome del tuo file
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_preview.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';

// Importiamo la nostra controfigura
import '../../../../testing/mocks/chatbot/mock_chatbot_repository.dart';

void main() {
  group('ChatHistoryWidget Widget Test', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() async {
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);

      // Prepariamo il mock con un paio di chat fittizie
      mockRepo.mockedPreviewsToReturn = [
        // NOTA: adatta i parametri del costruttore in base a come è fatto esattamente il tuo ChatPreview
        ChatPreview(id: '1', title: 'Indagine Omicidio', lastModified: DateTime.now()),
        ChatPreview(id: '2', title: 'Rapina in Banca', lastModified: DateTime.now()),
      ];

      // Diciamo al ViewModel di caricare questa lista iniziale
      await viewModel.loadChatPreviews();
    });

    /// Helper function per montare il widget all'interno di un finto ecosistema di navigazione
    Future<void> pumpDrawer(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ChatbotViewModel>.value(
            value: viewModel,
            child: Scaffold(
              // Inseriamo una finta AppBar per avere il "menu hamburger"
              appBar: AppBar(title: const Text('Home')),
              // Montiamo il tuo widget esattamente dove dovrebbe stare: nel drawer!
              drawer: const ChatHistoryWidget(),
            ),
          ),
        ),
      );

      // Ordiniamo al dito robotico di cliccare sull'icona del menu per aprire il Drawer
      await tester.tap(find.byIcon(Icons.menu));
      // Aspettiamo che l'animazione di scorrimento del menu sia finita
      await tester.pumpAndSettle();
    }

    testWidgets('Deve mostrare i titoli delle chat e le icone', (WidgetTester tester) async {
      await pumpDrawer(tester);

      // Verifichiamo che l'header sia presente
      expect(find.text('Cronologia Chat'), findsOneWidget);

      // Verifichiamo che i titoli delle due chat fittizie siano stampati a schermo
      expect(find.text('Indagine Omicidio'), findsOneWidget);
      expect(find.text('Rapina in Banca'), findsOneWidget);

      // Verifichiamo che ci siano i bottoni di eliminazione (uno per ogni chat)
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('Cliccare su una chat deve aprirla e chiudere il menu', (WidgetTester tester) async {
      await pumpDrawer(tester);

      // Prepariamo il mock per quando il ViewModel chiamerà getChatById('1')
      mockRepo.mockedChatToReturn = LocalChat(
          id: '1', title: 'Indagine Omicidio', creationDate: DateTime.now(), messages: []
      );

      // Tappiamo sul titolo della prima chat
      await tester.tap(find.text('Indagine Omicidio'));
      await tester.pumpAndSettle();

      // VERIFICA 1: Il ViewModel ha impostato la chat corrente?
      expect(viewModel.currentChat, isNotNull);
      expect(viewModel.currentChat!.getId(), '1');

      // VERIFICA 2: Il Drawer si è chiuso? (Il Navigator.pop ha funzionato?)
      // Se si è chiuso, il testo "Cronologia Chat" non deve più essere visibile sullo schermo
      expect(find.text('Cronologia Chat'), findsNothing);
    });

    testWidgets('Cliccare sull\'icona cestino deve eliminare la chat', (WidgetTester tester) async {
      await pumpDrawer(tester);

      // TRUCCO DA MAESTRI: Prima di tappare "Elimina", modifichiamo la lista
      // del mock in modo che la chat '2' non ci sia più.
      // Così, quando il ViewModel ricaricherà le anteprime dopo aver eliminato,
      // riceverà la nuova lista senza quella chat!
      mockRepo.mockedPreviewsToReturn = [
        ChatPreview(id: '1', title: 'Indagine Omicidio', lastModified: DateTime.now()),
      ];

      // Troviamo tutti i bottoni "cestino" (ce ne sono 2). Clicchiamo il secondo (indice 1)
      final cestini = find.byIcon(Icons.delete_outline);
      await tester.tap(cestini.at(1));

      // Aspettiamo che il ViewModel faccia la chiamata di rete finta e che Flutter ridisegni lo schermo
      await tester.pumpAndSettle();

      // Verifichiamo che la seconda chat sia scomparsa dalla grafica!
      expect(find.text('Rapina in Banca'), findsNothing);
      expect(find.text('Indagine Omicidio'), findsOneWidget); // La prima deve esserci ancora
    });
  });
}