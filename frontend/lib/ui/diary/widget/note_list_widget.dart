import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_editor_widget.dart';
import 'package:provider/provider.dart';

/// Widget che visualizza la lista delle note appartenenti al diario in cui l'utente ha effettuato il login
class NoteListWidget extends StatelessWidget {
  const NoteListWidget({super.key});

  final String dayFormat = "d/M/y";
  final String timeFormat = "H:mm";

  /// Apre la schermata [NoteEditorWidget] per la nota cliccata nella ListView
  Future<void> _openNoteEditor(
    BuildContext context,
    DiaryViewModel vm,
    String noteId,
  ) async {
    await vm.openNote.runAsync(noteId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: NoteEditorWidget(
            selectedNote: vm.currentNote!,
            onDismiss: () {
              Navigator.pop(sheetContext);
              vm.loadNotes.run(DiarySession.session.loggedDiary!);
            },
          ),
        );
      },
    );
  }

  /// Apre un [AlertDialog] per confermare l'eliminazione della nota
  void _showDeleteConfirmation(
    BuildContext context,
    DiaryViewModel viewModel,
    String noteTitle,
    DateTime noteDate,
    String noteId,
  ) {
    final diarySession = DiarySession.session;
    if (diarySession.isDiaryAuth != null && diarySession.loggedDiary != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Elimina nota"),
            content: Text(
              "Eliminare definitivamente la nota $noteTitle creata il ${DateFormat(dayFormat).format(noteDate)} alle ${DateFormat(timeFormat).format(noteDate)}?\n"
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
                  viewModel.deleteNote.run((
                    noteId: noteId,
                    diary: diarySession.loggedDiary!,
                  ));
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
    return Consumer<DiaryViewModel>(
      builder: (context, viewModel, child) {
        // Aggiungiamo il ValueListenableBuilder in ascolto dello stato del comando!
        return ValueListenableBuilder<bool>(
          valueListenable: viewModel.loadNotes.isRunning,
          builder: (context, isRunning, _) {

            // Mostriamo il caricamento solo se sta girando E se la lista è vuota
            // (così evitiamo che la UI sfarfalli se facciamo un refresh in background)
            if (isRunning && viewModel.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }

            // Stato vuoto
            if (viewModel.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_card, size: 64, color: Colors.teal.shade200),
                    const SizedBox(height: 16),
                    Text(
                      'Nessuna nota presente nel diario',
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

            // Lista popolata
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.notes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final note = viewModel.notes[index];
                return ListTile(
                  onTap: () => _openNoteEditor(context, viewModel, note.id),
                  title: (note.title.isEmpty)
                      ? const Text(
                    "Nota senza titolo",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  )
                      : Text(
                    note.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Ultima modifica: ${DateFormat(dayFormat).format(note.updateDate)} alle ${DateFormat(timeFormat).format(note.updateDate)}\nData di creazione: ${DateFormat(dayFormat).format(note.creationDate)} alle ${DateFormat(timeFormat).format(note.creationDate)}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    padding: const EdgeInsets.only(top: 24),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(
                      context,
                      viewModel,
                      note.title.isEmpty ? "senza titolo" : note.title,
                      note.creationDate,
                      note.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
