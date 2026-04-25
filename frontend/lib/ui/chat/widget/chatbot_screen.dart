import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/locator.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/chatbot_view_model.dart';
import 'chat_widget.dart';
import 'chat_history_widget.dart';
import 'chatbot_mode_toggle_widget.dart';
import 'chatbot_send_message_widget.dart';


/// IL WRAPPER: Inietta il ViewModel.
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

/// LA VISTA PURA: Ascolta gli eventi per le SnackBar e disegna l'UI.
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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Modalità Chatbot'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_motion, size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Mirror', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0, bottom: 16.0),
                child: Text('Risponde in modo diretto e conciso, agendo come uno specchio per le tue richieste senza fare domande aggiuntive.'),
              ),
              Row(
                children: [
                  Icon(Icons.psychology, size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Detective', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text('Analizza a fondo il contesto, fa domande di chiarimento e cerca di risolvere problemi complessi esplorando ogni dettaglio.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ho capito'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  /// Helper per creare una SnackBar che non copra la barra dei messaggi
  void _showFloatingSnackBar(String message) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onError),
        ),
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
          leading: const BackButton(),
          title: const Text('Assistente AI'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info Modalità',
              onPressed: () => _showModeInfoDialog(context),
            ),
          ],
        ),
        drawer: const ChatHistoryWidget(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 2. SOTTO-BARRA: Controlli specifici della Chat
              Builder(builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                  ),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const ChatbotModeToggleWidget(),
                    ],
                  ),
                );
              }),
              // --- INDICATORE DI CARICAMENTO (Transizione Proxy) ---
              // Usiamo ValueListenableBuilder come in Trusted Contacts!
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

              // --- CORPO CENTRALE ---
              Expanded(
                child: Consumer<ChatbotViewModel>(
                  builder: (context, vm, child) =>
                      _buildMainContent(context, vm),
                ),
              ),

              // --- BARRA DI INPUT ---
              const ChatbotSendMessageWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper che usa i ValueListenableBuilder per intercettare SEMPRE gli errori,
  /// esattamente come hai fatto in TrustedContactScreen.
  Widget _buildMainContent(BuildContext context, ChatbotViewModel vm) {
    return ValueListenableBuilder<bool>(
      valueListenable: vm.loadChatPreviews.isRunning,
      builder: (context, isRunning, _) {
        // 1. Caso di Caricamento Iniziale
        if (isRunning && vm.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Controllo degli errori "ascoltando" direttamente command_it
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

            // 3. Caso in cui non c'è nessuna chat attiva
            if (vm.currentChat == null) {
              return const Center(
                child: Text("Seleziona una conversazione dal menu."),
              );
            }

            // 4. Caso di successo: mostra i messaggi
            return const ChatWidget();
          },
        );
      },
    );
  }
}