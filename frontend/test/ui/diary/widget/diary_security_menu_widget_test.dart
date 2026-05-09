import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_security_menu_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_password_setting_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockAccessVm;
  late MockCommand<String, void> mockLoginCmd;
  late MockCommand<void, void> mockLogoutCmd;
  late MockCommand<String, void> mockCreatePwdCmd;

  setUp(() {
    mockAccessVm = MockDiaryAccessViewModel();
    mockLoginCmd = MockCommand<String, void>();
    mockLogoutCmd = MockCommand<void, void>();
    mockCreatePwdCmd = MockCommand<String, void>();

    // Stubbing dei membri interni dei comandi per evitare NullPointer nella UI
    for (var cmd in [mockLoginCmd, mockLogoutCmd, mockCreatePwdCmd]) {
      when(() => cmd.isRunning).thenReturn(ValueNotifier<bool>(false));
      when(() => cmd.canRun).thenReturn(ValueNotifier<bool>(true));
    }

    // Stubbing AccessViewModel
    when(() => mockAccessVm.login).thenReturn(mockLoginCmd);
    when(() => mockAccessVm.logout).thenReturn(mockLogoutCmd);
    when(() => mockAccessVm.createInitialPassword).thenReturn(mockCreatePwdCmd);

    when(() => mockAccessVm.passwordError).thenReturn("");
    when(() => mockAccessVm.setupSuccess).thenReturn(false);
    when(() => mockAccessVm.asyncError).thenReturn(ValueNotifier<String?>(null));
    when(() => mockAccessVm.isAuthenticated).thenReturn(true);
    when(() => mockAccessVm.isCheckingStatus).thenReturn(false);
    when(() => mockAccessVm.needsInitialSetup).thenReturn(false);

    // Stubbing metodi void
    when(() => mockAccessVm.resetFormState()).thenAnswer((_) {});
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<DiaryAccessViewModel>.value(
      value: mockAccessVm,
      child: const MaterialApp(
        home: Scaffold(
          body: Center(child: DiarySecurityMenuWidget()),
        ),
      ),
    );
  }

  group('DiarySecurityMenuWidget', () {
    testWidgets('apre il menu popup e visualizza le opzioni', (tester) async {
      // Imposta una dimensione generosa per evitare overflow nei test
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text("Impostazioni Sicurezza"));
      await tester.pumpAndSettle();

      expect(find.text('Gestisci password fittizia'), findsOneWidget);
      expect(find.text('Modifica password reale'), findsOneWidget);
    });

    testWidgets('selezionando password fittizia apre il bottom sheet corretto', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text("Impostazioni Sicurezza"));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gestisci password fittizia'));
      await tester.pumpAndSettle();

      // Verifica la presenza del widget di impostazione
      expect(find.byType(DiaryPasswordSetting), findsOneWidget);
      expect(find.text('Password Diario Fittizio'), findsOneWidget);

      final settingWidget = tester.widget<DiaryPasswordSetting>(find.byType(DiaryPasswordSetting));
      expect(settingWidget.isModifyingRealPassword, isFalse);
    });

    testWidgets('selezionando password reale apre il bottom sheet corretto', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text("Impostazioni Sicurezza"));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Modifica password reale'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica Password Reale'), findsOneWidget);

      final settingWidget = tester.widget<DiaryPasswordSetting>(find.byType(DiaryPasswordSetting));
      expect(settingWidget.isModifyingRealPassword, isTrue);
    });
  });
}