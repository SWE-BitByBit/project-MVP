import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/chatbot_view_model.dart';
import 'chat_widget.dart';
import 'chat_history_widget.dart';
import 'chatbot_mode_toggle_widget.dart';
import 'chatbot_send_message_widget.dart';
import 'chatbot_mode_info_dialog_widget.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ChatbotViewModel>(),
      child: const ChatbotScreenView(),
    );
  }
}

class ChatbotScreenView extends StatefulWidget {
  const ChatbotScreenView({super.key});

  @override
  State<ChatbotScreenView> createState() => _ChatbotScreenViewState();
}

class _ChatbotScreenViewState extends State<ChatbotScreenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatbotViewModel>();

      vm.sendMessage.errors.addListener(() {
        if (vm.sendMessage.errors.value != null) {
          _showFloatingSnackBar("Invio fallito. Riprova.");
        }
      });

      vm.asyncError.addListener(() {
        if (vm.asyncError.value != null) {
          _showFloatingSnackBar(vm.asyncError.value!);

          vm.asyncError.value = null;
        }
      });
    });
  }

  /// Helper per mostrare il popup informativo sulle modalità
  void _showModeInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChatbotModeInfoDialog(),
    );
  }

  /// Helper per creare una SnackBar che non copra la barra dei messaggi
  void _showFloatingSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onError)),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        // Diamo un margine dal basso (es. 80 pixel) per scavalcare la barra di input
        margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Assistente AI'),
          centerTitle: true,
          leadingWidth: 80,
          leading: const ChatbotModeToggleWidget(),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info Modalità',
              onPressed: () => _showModeInfoDialog(context),
            ),
          ],
        ),
        drawer: Drawer(child: const ChatHistoryWidget()),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(color: colorScheme.surface),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          tooltip: 'Cronologia chat',
                        ),
                        Expanded(
                          child: Consumer<ChatbotViewModel>(
                            builder: (context, vm, child) => Text(
                              vm.currentChat?.title ?? 'Nuova Conversazione',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer<ChatbotViewModel>(
                builder: (context, vm, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: vm.openChat.isRunning,
                    builder: (context, isRunning, _) {
                      if (isRunning) return const LinearProgressIndicator();
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),

              Expanded(
                child: Consumer<ChatbotViewModel>(
                  builder: (context, vm, child) =>
                      _buildMainContent(context, vm),
                ),
              ),

              const ChatbotSendMessageWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper che usa i ValueListenableBuilder per intercettare gli errori.
  Widget _buildMainContent(BuildContext context, ChatbotViewModel vm) {
    return ValueListenableBuilder<bool>(
      valueListenable: vm.loadChatPreviews.isRunning,
      builder: (context, isRunning, _) {
        if (isRunning && vm.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder(
          valueListenable: vm.loadChatPreviews.errors,
          builder: (context, commandError, _) {
            // Caso di Errore Bloccante
            if (commandError != null && vm.chats.isEmpty) {
              return Center(
                child: ErrorIndicator(
                  title: "Errore di connessione",
                  label: "Riprova",
                  onPressed: () => vm.loadChatPreviews.run(null),
                ),
              );
            }

            if (vm.currentChat == null) {
              return const Center(
                child: Text("Seleziona una conversazione dal menu."),
              );
            }

            return const ChatWidget();
          },
        );
      },
    );
  }
}
