import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/chatbot_view_model.dart';
import 'chatbot_create_chat_widget.dart';

/// Corrisponde a ChatHistoryWidget nell'UML.
/// Gestisce la visualizzazione della cronologia delle conversazioni nel Drawer.
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
                viewModel.deleteChat.run(chatId);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: colorScheme.primaryContainer),
          child: Center(
            child: Text(
              'Cronologia Chat',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const ChatbotCreateChatWidget(),
        ),
        const Divider(),
        Expanded(
          child: Consumer<ChatbotViewModel>(
            builder: (context, vm, child) {
              final chats = vm.chats;

              if (chats.isEmpty) {
                return const Center(
                  child: Text('Nessuna conversazione salvata.'),
                );
              }

              return ListView.builder(
                padding: EdgeInsets
                    .zero, // Rimuove il padding di default che stacca la lista dall'header
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  final isSelected = vm.currentChat?.id == chat.id;

                  return ListTile(
                    leading: Icon(
                      Icons.history,
                      // UX: L'icona si colora se la chat è attiva
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      chat.title,
                      maxLines:
                          1, // Previene che titoli troppo lunghi rompano il layout
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        // Il testo diventa grassetto se la chat è attiva
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),

                    // Evidenziazione di background per la chat attiva
                    selected: isSelected,
                    selectedTileColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),

                    onTap: () {
                      Navigator.pop(context);

                      vm.openChat.run(chat.id);
                    },

                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _showDeleteConfirmation(
                        context,
                        vm,
                        chat.id,
                        chat.title,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
