import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';

/// Widget che gestisce la modifica delle note
///
/// Essendo consumer di [DiaryViewmodel] si aggiorna in seguito a cambiamenti di stato del ViewModel
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

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  late final TextEditingController _titleController;
  final _textControllers = <TextEditingController>[];
  final _imagePicker = ImagePicker();
  final _imageUrls = <String>[];
  final _audioUrls = <String>[];
  File? _currentImage;
  File? _currentAudio;
  final _elements = <Card>[];
  bool loading = false;

  //Rimuove l'elemento [noteElement] sia da [_elements] che dalla lista dei contenuti della nota aperta nell'editor
  void _removeNoteElement(NoteElement element, Card card) {
    final viewModel = context.read<DiaryViewmodel>();
    viewModel.removeNoteElement(widget.selectedNote, element);
    setState(() {
      _elements.remove(card);
    });
  }

  //Crea una [Card] rappresentante il [NoteElement] passato come parametro
  Card _createCard(NoteElement? element) {
    if (element != null) {
      switch (element.getType()) {
        case "text":
          TextEditingController noteTextController = TextEditingController(
            text: element.getContent(),
          );
          _textControllers.add(noteTextController);
          Card card = Card();
          card = Card(
            child: Row(
              //mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: noteTextController,
                    maxLines: null,
                    onChanged: (value) => element.setContent(value),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _removeNoteElement(element, card);
                  },
                ),
              ],
            ),
          );
          return card;
        case "image":
          _imageUrls.add(element.getContent());
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(File(element.getContent())),
                ),
              ],
            ),
          );
        case "audio":
          _audioUrls.add(element.getContent());
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text("NYI")],
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
    _titleController = TextEditingController(
      text: widget.selectedNote.getTitle(),
    );
    loading = true;
    loadNote();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  //Apre il selettore di immagini e imposta la variabile di utility [_currentImage] con il file scelto
  Future _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentImage = File(image.path);
      });
    }
  }

  //Mostra menu popup contentente tre bottoni per l'aggiunta di elementi nota
  void _showOptions(BuildContext context, Note note) async {
    final viewModel = context.read<DiaryViewmodel>();
    showMenu(
      position: RelativeRect.fromLTRB(100, 1000, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          onTap: () {
            viewModel.addNoteElement(note, "", note.getElementCount());
            setState(() {
              _elements.add(
                _createCard(note.getNoteElements()[note.getElementCount() - 1]),
              );
            });
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
            _pickImage();
            if (_currentImage != null) {
              viewModel.addNoteMediaElement(
                note,
                _currentImage!,
                "image",
                note.getElementCount(),
              );
              setState(() {
                _elements.add(
                  _createCard(
                    note.getNoteElements()[note.getElementCount() - 1],
                  ),
                );
                _currentImage = null;
              });
            }
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

  //Metodo per forzare il caricamento degli elementi della nota
  Future<void> loadNote() async {
    List<NoteElement> elems = widget.selectedNote.getNoteElements();
    await Future.delayed(
      Duration(milliseconds: 200),
      () => {
        setState(() {
          //Necessario risettare elems perchè altrimenti rimane vuoto per qualche ragione
          elems = widget.selectedNote.getNoteElements();
          for (int i = 0; i < elems.length; i++) {
            _elements.add(_createCard(elems[i]));
          }
          loading = false;
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              AppBar(backgroundColor: Colors.teal.shade200),
              TextField(
                controller: _titleController,
                maxLines: 1,
                maxLength: 24,
                decoration: InputDecoration(labelText: 'Titolo nota'),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text(
                "Creata il ${DateFormat("d/M/y").format(widget.selectedNote.getCreationDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getCreationDate())}",
              ),
              Text(
                "Ultima modifica: ${DateFormat("d/M/y").format(widget.selectedNote.getUpdateDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getUpdateDate())}",
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_elements.isEmpty == false) {
                      return ListView.builder(
                        itemCount: _elements.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _elements[index];
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 64,
                              color: Colors.teal.shade200,
                            ),
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
            onPressed: () => _showOptions(context, widget.selectedNote),
            backgroundColor: Colors.teal,
            tooltip: 'Scegli un elemento da aggiungere alla nota',
            child: const Icon(
              Icons.create_new_folder_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        //Salva nota sse è stata effettivamente caricata
        onPopInvokedWithResult: (didPop, result) {
          final viewModel = context.read<DiaryViewmodel>();
          viewModel.updateNoteTitle(_titleController.text);
          viewModel.saveNote(
            widget.selectedNote,
            DiarySession.session.loggedDiary!,
          );
        },
      );
    }
  }
}
