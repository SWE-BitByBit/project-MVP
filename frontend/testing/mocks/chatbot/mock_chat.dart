import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';

class MockChatMessage extends Mock implements ChatMessage {}

class MockChat extends Mock implements Chat {}
