import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
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
  final _audioPlayers = <AudioPlayer>[];
  final _imagePicker = ImagePicker();
  //final _imageUrls = <String>[];
  final _audioUrls = <String>[];
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

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _handlePlayer(AudioPlayer player) {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void _handleSeek(AudioPlayer player, double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  //Crea una [Card] rappresentante il [NoteElement] passato come parametro
  Card _createCard(NoteElement? element) {
    final viewModel = context.read<DiaryViewmodel>();
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
              children: [
                Expanded(
                  child: TextField(
                    controller: noteTextController,
                    maxLines: null,
                    onChanged: (value) =>
                        viewModel.updateNoteTextElement(element, value),
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
          //_imageUrls.add(element.getContent());
          Card card = Card();
          card = Card(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(File(element.getContent())),
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
        case "audio":
          //_audioUrls.add(element.getContent());
          Card card = Card();
          AudioPlayer player = AudioPlayer();
          player.setUrl(element.getContent());
          Duration position = Duration.zero;
          Duration duration = Duration.zero;
          card = Card(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Slider(
                        min: 0.0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) => _handleSeek(player, value),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              player.playing ? Icons.pause : Icons.play_arrow,
                            ),
                            onPressed: () => _handlePlayer(player),
                          ),
                          Text(
                            "${_formatDuration(position)}/${_formatDuration(duration)}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    player.stop;
                    player.dispose;
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
            _addImageElement(note);
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
            _addAudioElement(note);
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
  Future loadNote() async {
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

              /// Commentati finchè non capisco come farli aggiornare
              /*Text(
                "Ultima modifica: ${DateFormat("d/M/y").format(widget.selectedNote.getUpdateDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getUpdateDate())}",
              ),
              Text(
                "Creata il ${DateFormat("d/M/y").format(widget.selectedNote.getCreationDate())} alle ${DateFormat("H:mm").format(widget.selectedNote.getCreationDate())}",
              ),*/
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
