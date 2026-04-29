import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart'; // Importa l'editor
import 'package:provider/provider.dart';

class NoteActionsWidget extends StatelessWidget {
  const NoteActionsWidget({super.key});

  void _openEditor(BuildContext context, DiaryViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // SOLUZIONE: Rispetta la barra di stato
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: NoteEditorWidget(
            selectedNote: vm.currentNote!,
            onDismiss: () => Navigator.pop(sheetContext),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryViewModel>(
      builder: (context, vm, child) {
        final diarySession = DiarySession.session;

        if (diarySession.isDiaryAuth == true && diarySession.loggedDiary != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 130.0),
            child: FloatingActionButton(
              onPressed: () async {
                vm.createNewNote(diarySession.loggedDiary!);

                await vm.saveNote.runAsync((
                note: vm.currentNote!,
                diary: diarySession.loggedDiary!
                ));

                if (context.mounted && vm.currentNote != null) {
                  _openEditor(context, vm);
                }
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}