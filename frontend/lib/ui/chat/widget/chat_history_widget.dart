import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

/// Corrisponde a ChatHistoryWidget nell'UML.
/// Gestisce la visualizzazione della cronologia delle conversazioni.
class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    ChatbotViewModel viewModel,
    String chatId,
    String chatTitle,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Elimina chat"),
          content: Text(
            "Eliminare definitivamente la conversazione '$chatTitle'?\n"
            "Una volta confermata l'eliminazione, la chat non potrà più essere recuperata.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Annulla",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.deleteChat(chatId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Elimina',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch permette al drawer di aggiornarsi se la lista dei preview cambia
    final viewModel = context.watch<ChatbotViewModel>();

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Center(
              child: Text(
                'Cronologia Chat',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.chatPreviews.length,
              itemBuilder: (context, index) {
                final preview = viewModel.chatPreviews[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(preview.getTitle()),
                  onTap: () {
                    viewModel.openChat(preview.getId());
                    Navigator.pop(
                      context,
                    ); // Chiude il drawer dopo la selezione
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(
                      context,
                      viewModel,
                      preview.getId(),
                      preview.getTitle(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
