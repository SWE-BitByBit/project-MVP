import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/chatbot_view_model.dart';

class ChatbotSendMessageWidget extends StatefulWidget {
  const ChatbotSendMessageWidget({super.key});

  @override
  State<ChatbotSendMessageWidget> createState() =>
      _ChatbotSendMessageWidgetState();
}

class _ChatbotSendMessageWidgetState extends State<ChatbotSendMessageWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ChatbotViewModel>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.teal.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Scrivi qui...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(viewModel),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSend(viewModel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSend(ChatbotViewModel vm) {
    if (_controller.text.isNotEmpty) {
      vm.sendChatMessage(_controller.text);
      _controller.clear();
    }
  }
}
