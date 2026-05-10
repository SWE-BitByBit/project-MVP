import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/core/dashboard_item.dart';
import 'package:command_it/command_it.dart';

class MockHomeViewModel extends Mock implements HomeViewModel {}

class MockCommandDashboard extends Mock implements Command<void, List<DashboardItem>> {}

class MockCommandError extends Mock implements CommandError<void> {}