import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

/// Corrisponde a ChatHistoryWidget nell'UML.
/// Gestisce la visualizzazione della cronologia delle conversazioni.
class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({super.key});

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
                  title: Text(preview.title),
                  onTap: () {
                    viewModel.openChat(preview.id);
                    Navigator.pop(context); // Chiude il drawer dopo la selezione
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => viewModel.deleteChat(preview.id),
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