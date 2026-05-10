import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';

import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';
import '../../../../testing/mocks/diary/mock_diary_view_model.dart';

void main() {
  late MockDiaryAccessViewModel mockAccessVm;
  late MockDiaryViewModel mockDiaryVm;

  late MockCommand<String, void> mockLoginCommand;
  late MockCommand<void, void> mockLogoutCommand;
  late MockCommand<DiaryType, void> mockLoadNotesCommand;
  late MockCommand<String, void> mockCreatePwdCommand;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
  });

  setUp(() {
    mockAccessVm = MockDiaryAccessViewModel();
    mockDiaryVm = MockDiaryViewModel();

    mockLoginCommand = MockCommand<String, void>();
    mockLogoutCommand = MockCommand<void, void>();
    mockLoadNotesCommand = MockCommand<DiaryType, void>();
    mockCreatePwdCommand = MockCommand<String, void>();

    for (var cmd in [mockLoginCommand, mockLogoutCommand, mockLoadNotesCommand ,mockCreatePwdCommand]) {
      when(() => cmd.isRunning).thenReturn(ValueNotifier<bool>(false));
      when(() => cmd.canRun).thenReturn(ValueNotifier<bool>(true));
    }

    // Stubbing AccessViewModel Properties
    when(() => mockAccessVm.login).thenReturn(mockLoginCommand);
    when(() => mockAccessVm.logout).thenReturn(mockLogoutCommand);
    when(() => mockAccessVm.createInitialPassword).thenReturn(mockCreatePwdCommand);
    when(() => mockAccessVm.asyncError).thenReturn(ValueNotifier<String?>(null));
    when(() => mockAccessVm.isCheckingStatus).thenReturn(false);
    when(() => mockAccessVm.isAuthenticated).thenReturn(false);
    when(() => mockAccessVm.needsInitialSetup).thenReturn(false); // Fix crash #1
    when(() => mockAccessVm.passwordError).thenReturn("");

    // Stubbing DiaryViewModel Properties
    when(() => mockDiaryVm.loadNotes).thenReturn(mockLoadNotesCommand);
    when(() => mockDiaryVm.asyncError).thenReturn(ValueNotifier<String?>(null));
    when(() => mockDiaryVm.notes).thenReturn([]);
    when(() => mockLoadNotesCommand.run(any())).thenAnswer((_) async {});

    final getIt = GetIt.instance;
    if (getIt.isRegistered<DiaryViewModel>()) {
      getIt.unregister<DiaryViewModel>();
    }
    getIt.registerSingleton<DiaryViewModel>(mockDiaryVm);

    DiarySession.session.isDiaryAuth = false;
    DiarySession.session.loggedDiary = null;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<DiaryAccessViewModel>.value(
        value: mockAccessVm,
        child: const DiaryScreen(),
      ),
    );
  }

  group('DiaryScreen - Switching Logic', () {
    testWidgets('mostra CircularProgressIndicator quando isCheckingStatus è true', (tester) async {
      when(() => mockAccessVm.isCheckingStatus).thenReturn(true);
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra DiaryAccessScreenView quando isAuthenticated è false', (tester) async {
      when(() => mockAccessVm.isAuthenticated).thenReturn(false);
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(DiaryAccessScreenView), findsOneWidget);
    });

    testWidgets('mostra DiaryScreenView quando isAuthenticated è true', (tester) async {
      when(() => mockAccessVm.isAuthenticated).thenReturn(true);
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(DiaryScreenView), findsOneWidget);
    });
  });

  group('DiaryScreenView - Functionality', () {
    testWidgets('carica le note all\'inizializzazione se autenticato', (tester) async {
      when(() => mockAccessVm.isAuthenticated).thenReturn(true);
      DiarySession.session.loggedDiary = DiaryType.real_diary;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      verify(() => mockLoadNotesCommand.run(DiaryType.real_diary)).called(1);
    });

    testWidgets('visualizza SnackBar in caso di errore asincrono', (tester) async {
      final errorNotifier = ValueNotifier<String?>(null);
      when(() => mockDiaryVm.asyncError).thenReturn(errorNotifier);
      when(() => mockAccessVm.isAuthenticated).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      errorNotifier.value = "Errore mock";
      await tester.pump();

      expect(find.text("Errore mock"), findsOneWidget);
    });

    testWidgets('il pulsante di logout attiva il comando corretto', (tester) async {
      when(() => mockAccessVm.isAuthenticated).thenReturn(true);
      when(() => mockLogoutCommand.run()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.lock_outline));
      await tester.pump();

      verify(() => mockLogoutCommand.run()).called(1);
    });
  });
}