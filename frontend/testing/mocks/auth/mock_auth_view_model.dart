import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';

class MockAuthViewModel extends Mock with ChangeNotifier implements AuthViewModel {}

class MockLoginCommand extends Mock implements Command<void, void> {}

class MockLogoutCommand extends Mock implements Command<void, void> {}