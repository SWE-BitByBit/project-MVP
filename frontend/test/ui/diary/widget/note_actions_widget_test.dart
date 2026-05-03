import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';
import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';


void main() {
  late MockDiaryViewModel mockVm;
  late MockCommand<({Note note, DiaryType diary}), void> mockSaveNoteCommand;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
    registerFallbackValue((
    note: LocalNote(
      id: 'fake',
      title: '',
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
    ),
    diary: DiaryType.real_diary
    ));
  });

  setUp(() {
    mockVm = MockDiaryViewModel();
    mockSaveNoteCommand = MockCommand<({Note note, DiaryType diary}), void>();

    // Stubbing obbligatorio per i membri interni dei comandi
    when(() => mockSaveNoteCommand.isRunning).thenReturn(ValueNotifier(false));
    when(() => mockSaveNoteCommand.canRun).thenReturn(ValueNotifier(true));

    // Assicuriamoci che il comando asincrono completi immediatamente
    when(() => mockSaveNoteCommand.runAsync(any())).thenAnswer((_) async => {});

    when(() => mockVm.saveNote).thenReturn(mockSaveNoteCommand);
    when(() => mockVm.asyncError).thenReturn(ValueNotifier(null));
    when(() => mockVm.notes).thenReturn([]);

    // Reset Singleton Session
    DiarySession.session.isDiaryAuth = false;
    DiarySession.session.loggedDiary = null;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<DiaryViewModel>.value(
          value: mockVm,
          child: const NoteActionsWidget(),
        ),
      ),
    );
  }

  group('NoteActionsWidget - Tests', () {


    testWidgets('non mostra il pulsante se non autenticato', (tester) async {
      DiarySession.session.isDiaryAuth = false;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}