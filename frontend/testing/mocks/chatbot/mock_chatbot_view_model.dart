import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';

class MockChatbotViewModel extends Mock with ChangeNotifier implements ChatbotViewModel {}

class MockCommand<T, R> extends Mock implements Command<T, R> {}