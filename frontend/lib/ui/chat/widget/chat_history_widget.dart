import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/chatbot/chat.dart';
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

  Future<void> _showEditTitleDialog(
    BuildContext context,
    dynamic vm,
    String chatId,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);

    await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Modifica titolo'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nuovo titolo'),
              onSubmitted: (value) {
                Navigator.pop(context, value.trim());
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, controller.text.trim());
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ).then((newTitle) {
          if (newTitle != null && newTitle != currentTitle) {
            vm.updateTitle.run((chatId: chatId, newTitle: newTitle));
          }
        });
  }

  Widget _buildChatTile(
    BuildContext context,
    ChatbotViewModel vm,
    Chat chat,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return ListTile(
      title: Text(
        chat.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: () {
        Navigator.pop(context);
        vm.openChat.run(chat.id);
      },
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (action) async {
          if (action == 'edit') {
            _showEditTitleDialog(context, vm, chat.id, chat.title);
          }

          if (action == 'delete') {
            _showDeleteConfirmation(context, vm, chat.id, chat.title);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined),
                SizedBox(width: 12),
                Text('Modifica titolo'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 12),
                Text('Elimina nota', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
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
                padding: EdgeInsets.zero,
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final isSelected = vm.currentChat?.id == chat.id;

                  return _buildChatTile(
                    context,
                    vm,
                    chat,
                    isSelected,
                    colorScheme,
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
