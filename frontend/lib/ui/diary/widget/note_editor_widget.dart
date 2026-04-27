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
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/options_menu_widget.dart';

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
  bool showDeleteButton = false;
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

  Widget _deleteCardOptionMenu(VoidCallback onDelete) {
    return OptionsMenu<String>(
      items: const [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Elimina', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
    );
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 40,
                    top: 8,
                    left: 8,
                    bottom: 8,
                  ),
                  child: TextField(
                    controller: noteTextController,
                    maxLines: null,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      viewModel.updateNoteTextElement(
                        widget.selectedNote,
                        element,
                        value,
                      );

                      setState(() {
                        _lastUpdated = widget.selectedNote.getUpdateDate();
                      });
                    },
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: _deleteCardOptionMenu(() {
                    _removeNoteElement(element, card);
                  }),
                ),
              ],
            ),
          );
          return card;
        case "image":
          card = Card(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 40,
                    top: 8,
                    left: 8,
                    bottom: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(File(element.getContent())),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: _deleteCardOptionMenu(() {
                    _removeNoteElement(element, card);
                  }),
                ),
              ],
            ),
          );
          return card;
        case "audio":
          card = Card(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 40,
                    top: 8,
                    left: 8,
                    bottom: 8,
                  ),
                  child: NoteAudioPlayerWidget(
                    onDismiss: () {
                      dispose();
                    },
                    trackUrl: element.getContent(),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: _deleteCardOptionMenu(() {
                    _removeNoteElement(element, card);
                  }),
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
      return const Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        child: Scaffold(
          backgroundColor: Colors.teal.shade50,
          body: Column(
            children: <Widget>[
              AppBar(backgroundColor: Colors.teal.shade200),
              Container(
                padding: const EdgeInsetsGeometry.directional(
                  top: 24,
                  start: 24,
                  end: 24,
                  bottom: 24,
                ),
                color: const Color.fromARGB(255, 201, 233, 232),

                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      maxLines: null,
                      maxLength: 64,
                      decoration: const InputDecoration(
                        hintText: 'Titolo nota',
                        hintStyle: TextStyle(color: Colors.black45),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                      onChanged: (value) => {_updateNoteTitle(value)},
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Text(
                        "Creata il ${DateFormat(dayFormat).format(widget.selectedNote.getCreationDate())} alle ${DateFormat(timeFormat).format(widget.selectedNote.getCreationDate())}",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Text(
                        "Ultima modifica: ${DateFormat(dayFormat).format(_lastUpdated!)} alle ${DateFormat(timeFormat).format(_lastUpdated!)}",
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_elements.isEmpty == false) {
                      return ListView.builder(
                        padding: const EdgeInsetsGeometry.directional(
                          start: 8,
                          end: 8,
                        ),
                        itemCount: _elements.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _elements[index];
                        },
                      );
                    } else {
                      return Transform.translate(
                        offset: const Offset(0, -28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 64,
                              color: Colors.teal.shade200,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Questa nota è vuota",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 89, 95, 95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Aggiungi un elemento con il pulsante qui sotto.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 135, 141, 141),
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
