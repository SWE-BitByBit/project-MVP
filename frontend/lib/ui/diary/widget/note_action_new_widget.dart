import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:provider/provider.dart';

class NoteActionNewWidget extends StatelessWidget {
  const NoteActionNewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DiaryViewmodel>();
    final diarySession = DiarySession.session;
    if (diarySession.isDiaryAuth != null) {
      return FloatingActionButton(
        onPressed: () => vm.addNewNote(diarySession.loggedDiary!),
        backgroundColor: Colors.teal,
        tooltip: 'Crea una nuova nota',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      );
    } else {
      return Scaffold();
    }
  }
}
