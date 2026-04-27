import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_audio_player_widget.dart';
import 'package:provider/provider.dart';

import '../../../../testing/mocks/mock_diary_account_repository.dart';
import '../../../../testing/mocks/mock_note_repository.dart';

void main() {
  group("NoteAudioPlayerWidget Widget Test", () {
    late MockNoteRepository mockRepo;
    late MockDiaryAccountRepository mockAccRepo;
    late DiaryViewmodel viewmodel;

    setUp(() {
      mockRepo = MockNoteRepository();
      mockAccRepo = MockDiaryAccountRepository();
      viewmodel = DiaryViewmodel(mockRepo, mockAccRepo);
    });

    Future<void> pumpPlayerWidget(
      WidgetTester tester, {
      required VoidCallback onDismiss,
      required String track,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<DiaryViewmodel>.value(
              value: viewmodel,
              child: NoteAudioPlayerWidget(
                onDismiss: onDismiss,
                trackUrl: track,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      "Il widget mostra correttamento lo Slider rappresentante la durata della traccia audio.",
      (WidgetTester tester) async {
        await pumpPlayerWidget(tester, onDismiss: () {}, track: "/");
        await tester.pumpAndSettle();
        expect(find.byType(Slider), findsOne);
      },
    );

    testWidgets("Il widget mostra correttamente i bottoni play e stop", (
      WidgetTester tester,
    ) async {
      await pumpPlayerWidget(tester, onDismiss: () {}, track: "/");
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsExactly(2));
      expect(find.byIcon(Icons.stop), findsOne);
      expect(find.byIcon(Icons.play_arrow), findsOne);
    });
  });
}
