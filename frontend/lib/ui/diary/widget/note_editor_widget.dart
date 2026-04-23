import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_audio_player_widget.dart';
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

  DateTime? _lastUpdated;
  final _imagePicker = ImagePicker();
  final _elements = <Card>[];
  bool loading = false;

  final String dayFormat = "d/M/y";
  final String timeFormat = "H:mm";

  //Rimuove l'elemento [noteElement] sia da [_elements] che dalla lista dei contenuti della nota aperta nell'editor
  void _removeNoteElement(NoteElement element, Card card) {
    final viewModel = context.read<DiaryViewmodel>();
    viewModel.removeNoteElement(widget.selectedNote, element);
    setState(() {
      _elements.remove(card);
      _lastUpdated = widget.selectedNote.getUpdateDate();
    });
  }

  //Crea una [Card] rappresentante il [NoteElement] passato come parametro
  Card _createCard(NoteElement? element) {
    final viewModel = context.read<DiaryViewmodel>();
    Card card = const Card();
    if (element != null) {
      switch (element.getType()) {
        case "text":
          TextEditingController noteTextController = TextEditingController(
            text: element.getContent(),
          );
          _textControllers.add(noteTextController);

          card = Card(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteTextController,
                    maxLines: null,
                    onChanged: (value) => {
                      viewModel.updateNoteTextElement(
                        widget.selectedNote,
                        element,
                        value,
                      ),
                      setState(() {
                        _lastUpdated = widget.selectedNote.getUpdateDate();
                      }),
                    },
                  ),
                ),
                const SizedBox(width: 16),
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
          card = Card(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(File(element.getContent())),
                  ),
                ),
                const SizedBox(width: 16),
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
        case "audio":
          card = Card(
            child: Row(
              children: [
                Expanded(
                  child: NoteAudioPlayerWidget(
                    onDismiss: () {
                      dispose();
                    },
                    trackUrl: element.getContent(),
                  ),
                ),

                /// Gestione audio delegata ad un widget separato
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
        default:
      }
    }
    return const Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: []),
    );
  }

  @override
  void initState() {
    _titleController = TextEditingController(
      text: widget.selectedNote.getTitle(),
    );
    _lastUpdated = widget.selectedNote.getUpdateDate();
    loading = true;
    loadNote();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _textControllers.map((c) => c.dispose());
  }

  //Apre il selettore di immagini e aggiunge l'immagine scelta alla nota
  Future _addImageElement(Note note) async {
    final viewModel = context.read<DiaryViewmodel>();
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File pickedImage = File(image.path);
      viewModel.addNoteMediaElement(
        note,
        pickedImage,
        "image",
        note.getElementCount(),
      );
      setState(() {
        _elements.add(
          _createCard(note.getNoteElements()[note.getElementCount() - 1]),
        );
        _lastUpdated = widget.selectedNote.getUpdateDate();
      });
    }
  }

  Future _addAudioElement(Note note) async {
    final viewModel = context.read<DiaryViewmodel>();
    final pickResult = await FilePicker.pickFiles(type: FileType.audio);
    if (pickResult != null) {
      final File audioFile = File(pickResult.files.single.path!);
      viewModel.addNoteMediaElement(
        note,
        audioFile,
        "audio",
        note.getElementCount(),
      );
      setState(() {
        _elements.add(
          _createCard(note.getNoteElements()[note.getElementCount() - 1]),
        );
        _lastUpdated = widget.selectedNote.getUpdateDate();
      });
    }
  }

  ///Aggiorna il titolo della nota usando il viewmodel
  void _updateNoteTitle(String title) {
    final viewModel = context.read<DiaryViewmodel>();
    viewModel.updateNoteTitle(title);
    setState(() {
      _lastUpdated = widget.selectedNote.getUpdateDate();
    });
  }

  //Mostra menu popup contentente tre bottoni per l'aggiunta di elementi nota
  void _showOptions(BuildContext context, Note note) async {
    final viewModel = context.read<DiaryViewmodel>();
    showMenu(
      position: const RelativeRect.fromLTRB(100, 1000, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          onTap: () {
            viewModel.addNoteElement(note, "", note.getElementCount());
            setState(() {
              _elements.add(
                _createCard(note.getNoteElements()[note.getElementCount() - 1]),
              );
              _lastUpdated = widget.selectedNote.getUpdateDate();
            });
          },
          child: const Row(
            children: [
              Icon(Icons.textsms),
              SizedBox(width: 10),
              Expanded(child: Text("Aggiungi testo")),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _addImageElement(note);
          },
          child: const Row(
            children: [
              Icon(Icons.photo),
              SizedBox(width: 10),
              Expanded(child: Text("Aggiungi immagine")),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            _addAudioElement(note);
          },
          child: const Row(
            children: [
              Icon(Icons.multitrack_audio),
              SizedBox(width: 10),
              Expanded(child: Text("Aggiungi traccia audio")),
            ],
          ),
        ),
      ],
    );
  }

  //Metodo per forzare il caricamento degli elementi della nota
  Future loadNote() async {
    List<NoteElement> elems = widget.selectedNote.getNoteElements();
    await Future.delayed(
      const Duration(milliseconds: 200),
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
                decoration: const InputDecoration(labelText: 'Titolo nota'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                onChanged: (value) => {_updateNoteTitle(value)},
              ),

              Text(
                "Ultima modifica: ${DateFormat(dayFormat).format(_lastUpdated!)} alle ${DateFormat(timeFormat).format(_lastUpdated!)}",
              ),
              Text(
                "Creata il ${DateFormat(dayFormat).format(widget.selectedNote.getCreationDate())} alle ${DateFormat(timeFormat).format(widget.selectedNote.getCreationDate())}",
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
