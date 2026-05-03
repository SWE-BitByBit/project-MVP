import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_tab_view_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_dashboard_widget.dart';

import '../../../../testing/mocks/home/mock_home_view_model.dart';

void main() {
  late MockHomeViewModel mockVm;
  late MockCommandDashboard mockLoadCommand;

  setUp(() {
    mockVm = MockHomeViewModel();
    mockLoadCommand = MockCommandDashboard();

    // Setup GetIt
    final sl = GetIt.instance;
    if (sl.isRegistered<HomeViewModel>()) {
      sl.unregister<HomeViewModel>();
    }
    sl.registerSingleton<HomeViewModel>(mockVm);

    // Stubbing minimi per HomeDashboardWidget (figlio di HomeTabView)
    when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier(false));
    when(() => mockLoadCommand.errors).thenReturn(ValueNotifier(null));
    when(() => mockLoadCommand.value).thenReturn([]);
    when(() => mockVm.loadDashboard).thenReturn(mockLoadCommand);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      // Definiamo rotte fittizie per testare la navigazione dei pulsanti dell'AppBar
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(body: Text("Screen: ${settings.name}")),
      ),
      home: const HomeTabView(),
    );
  }

  group('HomeTabView - UI & Rendering', () {
    testWidgets('renderizza correttamente l\'AppBar con titolo e icone', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Homepage'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('visualizza HomeDashboardWidget nel corpo della schermata', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(HomeDashboardWidget), findsOneWidget);
    });
  });

  group('HomeTabView - Navigation', () {
    testWidgets('il tasto profilo naviga verso la rotta /login', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      expect(find.text('Screen: /login'), findsOneWidget);
    });

    testWidgets('il tasto impostazioni naviga verso la rotta /settings', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Screen: /settings'), findsOneWidget);
    });
  });
}