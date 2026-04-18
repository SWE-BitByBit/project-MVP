import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:provider/provider.dart';

class NoteListWidget extends StatelessWidget {
  const NoteListWidget({super.key});
  void _openNoteEditor(BuildContext context, DiaryViewmodel vm, int index) {
    vm.loadNote(index);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: NoteEditorWidget(
            selectedNote: vm.getCurrentNote()!,
            onDismiss: () {
              () {
                Navigator.pop(sheetContext);
                vm.loadPreviews(DiarySession.session.loggedDiary!);
              };
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DiaryViewmodel viewModel,
    String noteTitle,
    DateTime noteDate,
    int index,
  ) {
    final diarySession = DiarySession.session;
    if (diarySession.isDiaryAuth != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Elimina nota"),
            content: Text(
              "Eliminare definitivamente la nota $noteTitle creata il ${DateFormat.yMMMMd().format(noteDate)} alle ${DateFormat("H:mm").format(noteDate)}?\n"
              "Una volta confermata l'eliminazione la nota non potrà più essere recuperata.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Annulla",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  viewModel.deleteNote(index, diarySession.loggedDiary!);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Elimina',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiaryViewmodel>();

    if (viewModel.isLoading()) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (viewModel.getSavedNotes().isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_card, size: 64, color: Colors.teal.shade200),
              const SizedBox(height: 16),
              Text(
                'Nessun nota presente nel diario',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.getNoteListSize(),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final note = viewModel.getSavedNotes()[index];
          return ListTile(
            onTap: () => _openNoteEditor(context, viewModel, index),
            title: Text(
              note.getTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "Ultima modifica: ${DateFormat("d/M/y").format(note.getUpdateDate())} alle ${DateFormat("H:mm").format(note.getUpdateDate())}\nData di creazione: ${DateFormat("d/M/y").format(note.getCreationDate())} alle ${DateFormat("H:mm").format(note.getCreationDate())}",
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(
                context,
                viewModel,
                note.getTitle(),
                note.getCreationDate(),
                index,
              ),
            ),
          );
        },
      );
    }
  }
}
