import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDiaryViewModel mockViewModel;
  late MockUpdateTitleCommand mockUpdateCommand;
  late MockAddElementCommand mockAddElementCommand;
  late MockDeleteNoteCommand mockDeleteCommand;
  late LocalNote testNote;

  setUpAll(() {
    // Mock del Platform Channel per flutter_secure_storage
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null; // Ritorna null per simulare successo su write/delete/read
    });

    registerFallbackValue((
    note: LocalNote(
      id: 'fake',
      title: '',
      creationDate: DateTime.now(),
      lastModified: DateTime.now(),
    ),
    diary: DiaryType.real_diary,
    ));

    registerFallbackValue((noteId: 'fake', diary: DiaryType.real_diary));
    registerFallbackValue((newTitle: 'fake', diary: DiaryType.real_diary));
    registerFallbackValue((type: 'text', text: 'fake', file: null, diary: DiaryType.real_diary));
  });

  setUp(() async {
    testNote = LocalNote(
      id: "test_id",
      title: "Titolo Iniziale",
      creationDate: DateTime(2026, 4, 30, 10, 0),
      lastModified: DateTime(2026, 4, 30, 10, 0),
    );

    mockViewModel = MockDiaryViewModel();
    mockUpdateCommand = MockUpdateTitleCommand();
    mockAddElementCommand = MockAddElementCommand();
    mockDeleteCommand = MockDeleteNoteCommand();

    when(() => mockViewModel.updateTitle).thenReturn(mockUpdateCommand);
    when(() => mockViewModel.addElement).thenReturn(mockAddElementCommand);
    when(() => mockViewModel.deleteNote).thenReturn(mockDeleteCommand);
    when(() => mockViewModel.currentNote).thenReturn(testNote);

    when(() => mockAddElementCommand.run(any())).thenAnswer((invocation) {
      final args = invocation.positionalArguments[0] as ({String type, String? text, dynamic file, DiaryType diary});
      final text = args.text;
      final elem = NoteTextElement(text ?? '');
      testNote.addElement(elem, testNote.getElementCount());
    });

    when(() => mockUpdateCommand.run(any())).thenAnswer((invocation) {
      final args = invocation.positionalArguments[0] as ({String newTitle, DiaryType diary});
      testNote.title = args.newTitle;
    });

    // Ora initSession non fallirà più grazie al mock del canale
    await DiarySession.session.initSession(DiaryType.real_diary, "test_token");

  });

  tearDown(() async {
    await DiarySession.session.endSession();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<DiaryViewModel>.value(
        value: mockViewModel,
        child: NoteEditorWidget(
          selectedNote: testNote,
          onDismiss: () {},
        ),
      ),
    );
  }

  group('NoteEditorWidget - UI Rendering', () {
    testWidgets('Visualizza correttamente il titolo e le date della nota', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Titolo Iniziale'), findsOneWidget);
      expect(find.textContaining('30/4/2026'), findsWidgets);
    });

    testWidgets('Mostra placeholder quando la nota è vuota', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text("Questa nota è vuota"), findsOneWidget);
    });
  });

  group('NoteEditorWidget - Logic & Persistence', () {
    testWidgets('Modifica del TextField titolo aggiorna l\'oggetto LocalNote', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField).first, "Titolo Modificato");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(testNote.title, "Titolo Modificato");
    });

    testWidgets('Aggiunta elemento testuale via FAB aggiorna la nota', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Aggiungi testo"));
      await tester.pumpAndSettle();
      expect(testNote.getElementCount(), 1);
      expect(testNote.noteElements.first, isA<NoteTextElement>());
    });


  });
}