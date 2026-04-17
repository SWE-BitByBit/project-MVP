import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';

class NoteEditorWidget extends StatefulWidget {
  //Callback per quando l'editor viene chiuso
  final VoidCallback onDismiss;

  //Nota da modificare
  final Note selectedNote;
  const NoteEditorWidget({
    super.key,
    required this.onDismiss,
    required this.selectedNote,
  });

  ///Bottone per l'inserimento di una nuova sezione
  ///bottone per l'eliminazione appare solo se l'elemento è selezionato
  ///Titolo in alto

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  late final TextEditingController _titleController;
  final _textControllers = <TextEditingController>[];
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  final _elements = <Card>[];
  bool loading = false;

  //Creazione elemento testuale
  Card _createCard(NoteElement? element) {
    if (element != null) {
      switch (element.getType()) {
        case "text":
          TextEditingController noteTextController = TextEditingController(
            text: element.getContent(),
          );
          _textControllers.add(noteTextController);
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [TextField(controller: noteTextController)],
            ),
          );
        default:
      }
    }
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: []),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.selectedNote.getTitle(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  void _showOptions(BuildContext context) async {
    final viewModel = context.read<DiaryViewmodel>();
    final note = viewModel.getCurrentNote();
    showMenu(
      position: RelativeRect.fromLTRB(100, 1000, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          onTap: () {
            viewModel.addNoteElement(note!, "", note.getElementCount());
          },
          child: Row(
            children: [
              const Icon(Icons.textsms),
              const SizedBox(width: 10),
              const Text("Aggiungi testo"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            /*viewModel.addNoteMediaElement(
              note!,
              _getImageFromGallery(),
              "image",
              note.getElementCount(),
            );*/
          },
          child: Row(
            children: [
              const Icon(Icons.photo),
              const SizedBox(width: 10),
              const Text("Aggiungi immagine"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            /*viewModel.addNoteMediaElement(
              note!,
              _getImageFromGallery(),
              "audio",
              note.getElementCount(),
            );*/
          },
          child: Row(
            children: [
              const Icon(Icons.multitrack_audio),
              const SizedBox(width: 10),
              const Text("Aggiungi traccia audio"),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          AppBar(backgroundColor: Colors.teal.shade200),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Titolo nota'),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            "Creata il ${DateFormat.yMMMMd().format(widget.selectedNote.getCreationDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getCreationDate())}",
          ),
          Text(
            "Ultima modifica: ${DateFormat.yMMMMd().format(widget.selectedNote.getUpdateDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getUpdateDate())}",
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_elements.isEmpty == false) {
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return _elements[index];
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 64, color: Colors.teal.shade200),
                        const SizedBox(height: 16),
                        Text(
                          "Questa nota è vuota",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aggiungi un elemento con il pulsante qui sotto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        onPressed: () => _showOptions(context),
        backgroundColor: Colors.teal,
        tooltip: 'Scegli un elemento da aggiungere alla nota',
        child: const Icon(
          Icons.create_new_folder_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
