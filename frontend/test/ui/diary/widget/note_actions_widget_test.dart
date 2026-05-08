import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';

class MockNote extends Mock implements Note {}

void main() {
  late MockDiaryViewModel mockVm;
  late MockNote mockNote;
  late DiaryType dummyDiary;

  setUp(() {
    mockVm = MockDiaryViewModel();
    mockNote = MockNote();
    dummyDiary = DiaryType.values.first;

    // --- FIX CRASH INIZIALIZZAZIONE ---
    // Il widget NoteEditorWidget, durante il suo initState, cerca di leggere
    // le proprietà della nota passata (come "title").
    // Poiché mockNote è un mock, restituiva "null" causando un TypeError.
    when(() => mockNote.title).thenReturn('Titolo di test');

    // NOTA: Se la tua classe "Note" richiede altri campi non-nullable letti
    // nell'editor (es. content, id, date), mockali qui sotto allo stesso modo.
    // when(() => mockNote.content).thenReturn('Contenuto di test');

    when(() => mockVm.asyncError).thenReturn(ValueNotifier(null));
    when(() => mockVm.notes).thenReturn([]);
    when(() => mockVm.createNewNote()).thenAnswer((_) {});

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

  group('NoteActionsWidget - Visibilità del FloatingActionButton', () {
    testWidgets('non mostra il pulsante se isDiaryAuth è false e loggedDiary è null', (tester) async {
      // Arrange
      DiarySession.session.isDiaryAuth = false;
      DiarySession.session.loggedDiary = null;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('non mostra il pulsante se isDiaryAuth è true ma loggedDiary è null', (tester) async {
      // Arrange
      DiarySession.session.isDiaryAuth = true;
      DiarySession.session.loggedDiary = null;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('non mostra il pulsante se loggedDiary non è null ma isDiaryAuth è false', (tester) async {
      // Arrange
      DiarySession.session.isDiaryAuth = false;
      DiarySession.session.loggedDiary = dummyDiary;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('mostra il pulsante se isDiaryAuth è true e loggedDiary non è null', (tester) async {
      // Arrange
      DiarySession.session.isDiaryAuth = true;
      DiarySession.session.loggedDiary = dummyDiary;

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('NoteActionsWidget - Interazioni e Navigazione', () {
    setUp(() {
      // Setup comune per mostrare il pulsante in questi test
      DiarySession.session.isDiaryAuth = true;
      DiarySession.session.loggedDiary = dummyDiary;
    });

    testWidgets('onPressed chiama createNewNote ma non apre il BottomSheet se currentNote è null', (tester) async {
      // Arrange
      when(() => mockVm.currentNote).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockVm.createNewNote()).called(1);
      expect(find.byType(NoteEditorWidget), findsNothing);
    });

  });
}