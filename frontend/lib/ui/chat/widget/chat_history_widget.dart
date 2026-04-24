import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/chatbot_view_model.dart';
import '../../../domain/models/chatbot/chat.dart';
import 'chatbot_create_chat_widget.dart';

/// Corrisponde a ChatHistoryWidget nell'UML.
/// Gestisce la visualizzazione della cronologia delle conversazioni nel Drawer.
class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Recuperiamo il colorScheme centralizzato per non avere colori hardcoded
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child:Column(
          children: [
            // 1. HEADER STATICO: Non avendo dati dinamici, sta fuori dal Consumer!
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
            // 2. LISTA DINAMICA: Avvolta nel Consumer per isolare i re-build
            Expanded(
              child: Consumer<ChatbotViewModel>(
                builder: (context, vm, child) {
                  // Usiamo la nuova proprietà 'chats' che contiene i ProxyChat
                  final chats = vm.chats;

                  if (chats.isEmpty) {
                    return const Center(
                      child: Text('Nessuna conversazione salvata.'),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero, // Rimuove il padding di default che stacca la lista dall'header
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];

                      // Controlliamo se questa riga è la chat che stiamo guardando ora
                      final isSelected = vm.currentChat?.id == chat.id;

                      return ListTile(
                        leading: Icon(
                          Icons.history,
                          // UX: L'icona si colora se la chat è attiva
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          chat.title,
                          maxLines: 1, // Previene che titoli troppo lunghi rompano il layout
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            // UX: Il testo diventa grassetto se la chat è attiva
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),

                        // UX: Evidenziazione di background per la chat attiva
                        selected: isSelected,
                        selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),

                        onTap: () {
                          // Chiudiamo il drawer PRIMA di lanciare il comando (UX più fluida)
                          Navigator.pop(context);

                          // 3. ESECUZIONE COMANDI: Usiamo .run() di command_it
                          vm.openChat.run(chat.id);
                        },

                        trailing: IconButton(
                          // Usiamo colorScheme.error invece di Colors.red
                          icon: Icon(Icons.delete_outline, color: colorScheme.error),
                          onPressed: () {
                            // ESECUZIONE COMANDI: Usiamo .run()
                            vm.deleteChat.run(chat.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}