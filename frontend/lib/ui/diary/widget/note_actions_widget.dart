import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:provider/provider.dart';

///Bottone per la creazione di una nuova [Note] e aggiunta alla lista delle note salvate della [DiarySession] attualmente attiva
class NoteActionsWidget extends StatelessWidget {
  const NoteActionsWidget({super.key});

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
