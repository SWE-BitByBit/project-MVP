import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/chatbot_service.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../view_model/chatbot_view_model.dart';
import 'chat_widget.dart';
import 'chat_history_widget.dart';
import 'chatbot_mode_toggle_widget.dart';
import 'chatbot_send_message_widget.dart';
import 'chatbot_create_chat_widget.dart';

/// 1. IL WRAPPER: Si occupa SOLO di creare le dipendenze vere per l'app in produzione.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = ChatbotService();
        final repo = ChatbotRepository(service);
        final vm = ChatbotViewModel(repo);
        vm.loadChatPreviews();
        vm.createChat();
        return vm;
      },
      child: const ChatScreenView(), // Richiama la UI pura
    );
  }
}

/// 2. LA VISTA PURA: Contiene tutta la grafica. È perfetta per essere testata!
class ChatScreenView extends StatelessWidget {
  const ChatScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        appBar: AppBar(
          title: const _AppBarTitle(),
          actions: const [
            ChatbotModeToggleWidget(),
            ChatbotCreateChatWidget(),
          ],
        ),
        drawer: const ChatHistoryWidget(),
        body: Column(
          children: [
            const Expanded(
              child: ChatWidget(),
            ),
            Consumer<ChatbotViewModel>(
              builder: (context, vm, child) {
                return Column(
                  children: [
                    if (vm.isLoading)
                      const LinearProgressIndicator(),
                    if (vm.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                );
              },
            ),
            const ChatbotSendMessageWidget(),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    final title = context.select<ChatbotViewModel, String>(
            (vm) => vm.currentChat?.getTitle() ?? 'Nuova Conversazione'
    );
    return Text(title);
  }
}