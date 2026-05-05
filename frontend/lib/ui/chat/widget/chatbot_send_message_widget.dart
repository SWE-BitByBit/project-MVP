import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/chatbot_view_model.dart';

/// Widget reattivo che rappresenta la barra di input per inviare i messaggi.
class ChatbotSendMessageWidget extends StatefulWidget {
  const ChatbotSendMessageWidget({super.key});

  @override
  State<ChatbotSendMessageWidget> createState() =>
      _ChatbotSendMessageWidgetState();
}

class _ChatbotSendMessageWidgetState extends State<ChatbotSendMessageWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Aggiorna lo stato locale quando l'utente digita per abilitare/disabilitare il tasto invia
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  /// Esegue l'invio del messaggio interfacciandosi con il ViewModel.
  void _sendMessage(ChatbotViewModel vm) {
    final text = _controller.text.trim();
    if (text.isEmpty || vm.currentChat == null) return;

    vm.sendMessage.run((chat: vm.currentChat!, content: text, mode: vm.mode));

    _controller.clear();
  }

  Widget _buildTextInput(BuildContext context, bool isEnabled) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: TextField(
          controller: _controller,
          enabled: isEnabled,
          maxLines: 5,
          minLines: 1,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: isEnabled
                ? 'Scrivi un messaggio...'
                : 'Seleziona una chat prima',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    ChatbotViewModel vm,
    bool canSend,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: vm.sendMessage.isRunning,
      builder: (context, isRunning, _) {
        return Container(
          decoration: BoxDecoration(
            color: canSend ? colorScheme.primary : colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: isRunning
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: canSend
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
            onPressed: canSend ? () => _sendMessage(vm) : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(color: Colors.teal.shade100),
        child: Consumer<ChatbotViewModel>(
          builder: (context, vm, child) {
            final hasActiveChat = vm.currentChat != null;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTextInput(context, hasActiveChat),

                const SizedBox(width: 8.0),

                // --- PULSANTE INVIA ---
                _buildSendButton(context, vm, hasActiveChat && hasText),
              ],
            );
          },
        ),
      ),
    );
  }
}
