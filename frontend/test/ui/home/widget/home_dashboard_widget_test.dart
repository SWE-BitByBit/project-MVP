import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_dashboard_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/core/dashboard_item.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/dashboard_button_widget.dart';

import '../../../../testing/mocks/home/mock_home_view_model.dart';

void main() {
  late MockHomeViewModel mockVm;
  late MockCommandDashboard mockLoadCommand;

  setUp(() {
    mockVm = MockHomeViewModel();
    mockLoadCommand = MockCommandDashboard();

    // Stubbing dei ValueListenable obbligatori
    when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockLoadCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));
    when(() => mockLoadCommand.value).thenReturn([]);

    when(() => mockVm.loadDashboard).thenReturn(mockLoadCommand);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(body: Text("Navigated to ${settings.name}")),
      ),
      home: Scaffold(
        // SOLUZIONE: Usiamo ChangeNotifierProvider invece di Provider
        body: ChangeNotifierProvider<HomeViewModel>.value(
          value: mockVm,
          child: const HomeDashboardWidget(),
        ),
      ),
    );
  }

  group('HomeDashboardWidget - States', () {
    testWidgets('mostra CircularProgressIndicator durante il caricamento iniziale', (tester) async {
      when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier<bool>(true));
      when(() => mockLoadCommand.value).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });


    testWidgets('mostra la lista di DashboardItem quando il caricamento ha successo', (tester) async {
      final items = [
        const DashboardItem(
          title: 'Contatti Fidati',
          description: 'Descrizione test',
          icon: Icons.group,
          backgroundColor: Colors.teal,
          iconColor: Colors.white,
          routeName: '/contacts',
        ),
      ];

      when(() => mockLoadCommand.value).thenReturn(items);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(DashboardButtonWidget), findsOneWidget);
      expect(find.text('Contatti Fidati'), findsOneWidget);
    });
  });

  group('HomeDashboardWidget - Navigation', () {
    testWidgets('naviga alla rotta corretta quando viene premuto un pulsante', (tester) async {
      final items = [
        const DashboardItem(
          title: 'Nav Card',
          description: 'Tap to navigate',
          icon: Icons.navigation,
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
          routeName: '/target_screen',
        ),
      ];

      when(() => mockLoadCommand.value).thenReturn(items);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Nav Card'));
      await tester.pumpAndSettle();

      expect(find.text("Navigated to /target_screen"), findsOneWidget);
    });
  });
}