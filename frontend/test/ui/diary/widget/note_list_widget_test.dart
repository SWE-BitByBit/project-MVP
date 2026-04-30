import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/local_note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';
import '../../../../testing/mocks/diary/mock_diary_access_view_model.dart';

void main() {
  late MockDiaryViewModel mockVm;
  late MockCommand<DiaryType, void> mockLoadNotesCommand;
  late MockCommand<String, void> mockOpenNoteCommand;
  late MockCommand<({String noteId, DiaryType diary}), void> mockDeleteNoteCommand;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
    registerFallbackValue((noteId: '1', diary: DiaryType.real_diary));
  });

  setUp(() {
    mockVm = MockDiaryViewModel();
    mockLoadNotesCommand = MockCommand<DiaryType, void>();
    mockOpenNoteCommand = MockCommand<String, void>();
    mockDeleteNoteCommand = MockCommand<({String noteId, DiaryType diary}), void>();

    // Stubbing Commands
    when(() => mockVm.loadNotes).thenReturn(mockLoadNotesCommand);
    when(() => mockVm.openNote).thenReturn(mockOpenNoteCommand);
    when(() => mockVm.deleteNote).thenReturn(mockDeleteNoteCommand);

    // Default status for Commands
    when(() => mockLoadNotesCommand.isRunning).thenReturn(ValueNotifier(false));
    when(() => mockOpenNoteCommand.runAsync(any())).thenAnswer((_) async {});
    when(() => mockDeleteNoteCommand.run(any())).thenReturn(null);

    // Reset Session Singleton
    DiarySession.session.isDiaryAuth = true;
    DiarySession.session.loggedDiary = DiaryType.real_diary;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<DiaryViewModel>.value(
          value: mockVm,
          child: const NoteListWidget(),
        ),
      ),
    );
  }

  group('NoteListWidget - Display', () {
    testWidgets('mostra CircularProgressIndicator quando loadNotes è in esecuzione', (tester) async {
      when(() => mockLoadNotesCommand.isRunning).thenReturn(ValueNotifier(true));
      when(() => mockVm.notes).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra stato vuoto quando non ci sono note', (tester) async {
      when(() => mockVm.notes).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nessuna nota presente nel diario'), findsOneWidget);
      expect(find.byIcon(Icons.add_card), findsOneWidget);
    });

    testWidgets('visualizza correttamente una lista di note', (tester) async {
      final note1 = LocalNote(
        id: '1',
        title: 'Nota Test 1',
        creationDate: DateTime(2023, 10, 1, 10, 30),
        lastModified: DateTime(2023, 10, 1, 11, 00),
      );
      final note2 = LocalNote(
        id: '2',
        title: '', // Senza titolo
        creationDate: DateTime(2023, 10, 2, 12, 00),
        lastModified: DateTime(2023, 10, 2, 12, 00),
      );

      when(() => mockVm.notes).thenReturn([note1, note2]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nota Test 1'), findsOneWidget);
      expect(find.text('Nota senza titolo'), findsOneWidget);
      expect(find.textContaining('Data di creazione: 1/10/2023'), findsOneWidget);
    });
  });

  group('NoteListWidget - Interactions', () {
    testWidgets('cliccando su una nota chiama openNote e apre l\'editor', (tester) async {
      final note = LocalNote(
        id: 'note_123',
        title: 'Apritimi',
        creationDate: DateTime.now(),
        lastModified: DateTime.now(),
      );
      when(() => mockVm.notes).thenReturn([note]);
      when(() => mockVm.currentNote).thenReturn(note);
      when(() => mockLoadNotesCommand.run(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Apritimi'));

      // Gestione asincronia runAsync e apertura BottomSheet
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockOpenNoteCommand.runAsync('note_123')).called(1);
      expect(find.byType(NoteEditorWidget), findsOneWidget);
    });

    testWidgets('cliccando sull\'icona delete mostra il dialogo di conferma', (tester) async {
      final note = LocalNote(
        id: 'id_del',
        title: 'Nota da eliminare',
        creationDate: DateTime(2023, 5, 5, 10, 00),
        lastModified: DateTime.now(),
      );
      when(() => mockVm.notes).thenReturn([note]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Eliminare definitivamente la nota Nota da eliminare'), findsOneWidget);
    });

    testWidgets('confermando l\'eliminazione chiama deleteNote sul ViewModel', (tester) async {
      final note = LocalNote(
        id: 'id_del',
        title: 'Eliminami',
        creationDate: DateTime.now(),
        lastModified: DateTime.now(),
      );
      when(() => mockVm.notes).thenReturn([note]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();

      verify(() => mockDeleteNoteCommand.run(any())).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}