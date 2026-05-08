import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';

// Sostituisci questi import con i percorsi reali della tua app
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_text_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_image_element.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_audio_element.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_audio_player_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/options_menu_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDiaryViewModel mockViewModel;
  late MockUpdateTitleCommand mockUpdateCommand;
  late MockAddElementCommand mockAddElementCommand;
  late MockDeleteNoteCommand mockDeleteCommand;
  late MockDeleteElementCommand mockDeleteElementCommand;
  late MockEditElementTextCommand mockEditElementTextCommand;
  late LocalNote testNote;

  final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  setUpAll(() {
    const storageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (MethodCall methodCall) async => null);

    const imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, (MethodCall methodCall) async => '/dummy/path.jpg');

    const filePickerChannel = MethodChannel('miguelruivo.flutter.plugins.filepicker');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(filePickerChannel, (MethodCall methodCall) async => [
      {'path': '/dummy/path.mp3', 'name': 'dummy.mp3', 'size': 0, 'bytes': null}
    ]);

    registerFallbackValue(LocalNote(id: 'fake', title: '', creationDate: DateTime.now(), lastModified: DateTime.now()));
    registerFallbackValue((noteId: 'fake', diary: DiaryType.real_diary));
    registerFallbackValue((newTitle: 'fake', diary: DiaryType.real_diary));
    registerFallbackValue((type: 'text', text: 'fake', file: null, diary: DiaryType.real_diary));

    // FIX CRITICO: Casting esplicito a "NoteElement" all'interno del Record per far combaciare
    // esattamente il tipo generico di mocktail per l'istruzione any()
    registerFallbackValue((
    element: NoteTextElement("") as NoteElement,
    newText: "fake",
    diary: DiaryType.real_diary
    ));
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
    mockDeleteElementCommand = MockDeleteElementCommand();
    mockEditElementTextCommand = MockEditElementTextCommand();

    when(() => mockViewModel.updateTitle).thenReturn(mockUpdateCommand);
    when(() => mockViewModel.addElement).thenReturn(mockAddElementCommand);
    when(() => mockViewModel.deleteNote).thenReturn(mockDeleteCommand);
    when(() => mockViewModel.deleteElement).thenReturn(mockDeleteElementCommand);
    when(() => mockViewModel.editElementText).thenReturn(mockEditElementTextCommand);
    when(() => mockViewModel.currentNote).thenReturn(testNote);
    when(() => mockViewModel.clearCurrentNote()).thenReturn(null);

    when(() => mockAddElementCommand.run(any())).thenAnswer((invocation) {
      final args = invocation.positionalArguments[0] as ({String type, String? text, dynamic file, DiaryType diary});
      testNote.addElement(NoteTextElement(args.text ?? ''), testNote.getElementCount());
    });
    when(() => mockUpdateCommand.run(any())).thenAnswer((invocation) {
      final args = invocation.positionalArguments[0] as ({String newTitle, DiaryType diary});
      testNote.title = args.newTitle;
    });
    when(() => mockDeleteElementCommand.run(any())).thenReturn(null);
    when(() => mockEditElementTextCommand.run(any())).thenReturn(null);

    await DiarySession.session.initSession(DiaryType.real_diary, "test_token");
  });

  tearDown(() async {
    await DiarySession.session.endSession();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      navigatorKey: navKey,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<DiaryViewModel>.value(
                    value: mockViewModel,
                    child: NoteEditorWidget(
                      selectedNote: testNote,
                      onDismiss: () {},
                    ),
                  ),
                ),
              );
            },
            child: const Text('Open Editor'),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Open Editor'));
    await tester.pumpAndSettle();
  }

  group('NoteEditorWidget - PopScope & Lifecycle', () {
    testWidgets('L\'uscita dalla schermata elimina elementi testo vuoti e pulisce la nota corrente', (tester) async {
      final emptyElement = NoteTextElement("");
      final validElement = NoteTextElement("Valido");
      testNote.addElement(emptyElement, 0);
      testNote.addElement(validElement, 1);

      await _openEditor(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      verify(() => mockDeleteElementCommand.run(emptyElement)).called(1);
      verifyNever(() => mockDeleteElementCommand.run(validElement));
      verify(() => mockViewModel.clearCurrentNote()).called(1);
    });
  });

  group('NoteEditorWidget - Logic & Focus', () {


    testWidgets('Modifica del TextField titolo chiama updateTitle al focus loss', (tester) async {
      await _openEditor(tester);
      final titleFinder = find.byType(TextField).first;

      await tester.tap(titleFinder);
      await tester.pumpAndSettle();

      await tester.enterText(titleFinder, "Titolo Modificato");
      await tester.pumpAndSettle();

      // FIX CRITICO: Estraiamo il vero FocusNode istanziato dal widget e lo spegniamo.
      final titleWidget = tester.widget<TextField>(titleFinder);
      titleWidget.focusNode?.unfocus();
      await tester.pumpAndSettle();

      verify(() => mockUpdateCommand.run(any())).called(1);
    });
  });

  group('NoteEditorWidget - UI Rendering Media Cards', () {
    testWidgets('Costruisce correttamente le card per immagini e audio', (tester) async {
      final imageElement = NoteImageElement("img", file: File("dummy.jpg"));
      final audioElement = NoteAudioElement("audio", file: File("dummy.mp3"));
      testNote.addElement(imageElement, 0);
      testNote.addElement(audioElement, 1);

      await _openEditor(tester);

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(NoteAudioPlayerWidget), findsOneWidget);
    });
  });

  group('NoteEditorWidget - Interaction & Options Menu', () {
    testWidgets('Aggiunta di immagine e audio tramite FAB chiama addElement', (tester) async {
      await _openEditor(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Aggiungi immagine"));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Aggiungi traccia audio"));
      await tester.pumpAndSettle();

      verify(() => mockAddElementCommand.run(any())).called(2);
    });

    testWidgets('Eliminazione elemento tramite menu sulla singola card', (tester) async {
      final textElement = NoteTextElement("Da cancellare");
      testNote.addElement(textElement, 0);

      await _openEditor(tester);

      await tester.tap(find.byType(OptionsMenu<String>).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();

      verify(() => mockDeleteElementCommand.run(textElement)).called(1);
    });
  });
}