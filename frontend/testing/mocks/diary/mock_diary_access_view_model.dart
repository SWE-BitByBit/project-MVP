import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart' hide MockCommand;
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

class MockDiaryAccessViewModel extends Mock with ChangeNotifier implements DiaryAccessViewModel {}

class MockCommand<T, R> extends Mock implements Command<T, R> {}