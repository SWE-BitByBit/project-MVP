import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';

import '../../../../testing/mocks/diary/mock_diary_view_model.dart';


void main() {
  late MockDiaryViewModel mockVm;

  setUp(() {
    mockVm = MockDiaryViewModel();
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