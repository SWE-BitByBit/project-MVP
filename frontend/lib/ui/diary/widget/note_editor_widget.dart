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
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/options_menu_widget.dart';

/// Widget che gestisce la modifica delle note
class NoteEditorWidget extends StatefulWidget {
  final VoidCallback onDismiss;

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
  final _focusNodes = <FocusNode>[];

  DateTime? _lastUpdated;
  final _imagePicker = ImagePicker();
  final _elements = <Card>[];
  bool showDeleteButton = false;
  bool loading = false;

  final String dayFormat = "d/M/y";
  final String timeFormat = "H:mm";

  /// Rimuove l'elemento [noteElement] dalla nota
  void _removeNoteElement(NoteElement element, Card card) {
    context.read<DiaryViewModel>().deleteElement(element);

    setState(() {
      _elements.remove(card);
      _lastUpdated = widget.selectedNote.updateDate;
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

  /// Crea una [Card] rappresentante il [NoteElement] passato come parametro
  Card _createCard(NoteElement? element, {bool requestFocus = false}) {
    Card card = const Card();
    if (element != null) {
      switch (element.type) {
        case "text":
          TextEditingController noteTextController = TextEditingController(
            text: element.content,
          );
          _textControllers.add(noteTextController);

          FocusNode focusNode = FocusNode();
          _focusNodes.add(focusNode);

          if (requestFocus) {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) focusNode.requestFocus();
            });
          }

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
                    focusNode: focusNode,
                    maxLines: null,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      widget.selectedNote.editNoteElement(element, value);

                      setState(() {
                        _lastUpdated = widget.selectedNote.updateDate;
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
                    child: Image.file(element.file!),
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
                    trackUrl: element.file!.path,
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
    super.initState();
    _titleController = TextEditingController(text: widget.selectedNote.title);
    _lastUpdated = widget.selectedNote.updateDate;

    loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _textControllers) {
      c.dispose();
    }

    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Gestisce l'acquisizione dell'input (se necessario), la chiamata al ViewModel
  /// e l'aggiornamento della UI per qualsiasi tipo di elemento.
  Future<void> _addNewElement(String type) async {
    File? pickedFile;
    bool requestFocus = false;

    // 1. Acquisizione del file (solo per i media)
    if (type == 'image') {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // L'utente ha chiuso il picker senza scegliere
      pickedFile = File(image.path);
    }
    else if (type == 'audio') {
      final pickResult = await FilePicker.pickFiles(type: FileType.audio);
      if (pickResult == null) return; // L'utente ha chiuso il picker senza scegliere
      pickedFile = File(pickResult.files.single.path!);
    }
    else if (type == 'text') {
      // Per il testo non serve un file, ma vogliamo che la tastiera si apra subito
      requestFocus = true;
    }

    // Se il widget è stato smontato mentre l'utente sceglieva il file, interrompiamo
    if (!mounted) return;

    // 2. Chiamata al ViewModel (ora identica per tutti!)
    final newElement = context.read<DiaryViewModel>().addElement(
      type: type,
      text: type == 'text' ? "" : null,
      file: pickedFile,
    );

    // 3. Aggiornamento visivo della UI
    setState(() {
      _elements.add(_createCard(newElement, requestFocus: requestFocus));
      _lastUpdated = widget.selectedNote.updateDate;
    });
  }

  /// Aggiorna il titolo della nota
  void _updateNoteTitle(String title) {
    setState(() {
      widget.selectedNote.title = title;
      _lastUpdated = widget.selectedNote.updateDate;
    });
  }

  /// Mostra menu popup contentente tre bottoni per l'aggiunta di elementi nota
  void _showOptions(BuildContext context) async {
    showMenu(
      position: const RelativeRect.fromLTRB(100, 1000, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          onTap: () => _addNewElement('text'), // <-- Guarda che pulizia!
          child: const Row(
            children: [
              Icon(Icons.textsms),
              SizedBox(width: 10),
              Expanded(child: Text("Aggiungi testo")),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _addNewElement('image'), // <-- Guarda che pulizia!
          child: const Row(
            children: [
              Icon(Icons.photo),
              SizedBox(width: 10),
              Expanded(child: Text("Aggiungi immagine")),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _addNewElement('audio'), // <-- Guarda che pulizia!
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

  /// Metodo per popolare la UI con gli elementi della nota
  void loadNote() {
    List<NoteElement> elems = widget.selectedNote.noteElements;
    for (int i = 0; i < elems.length; i++) {
      _elements.add(_createCard(elems[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryViewModel>(
      builder: (context, vm, child) {
        if (loading) return const Center(child: CircularProgressIndicator());

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            widget.selectedNote.title = _titleController.text.trim();

            // 1. PULIZIA ELEMENTI: Troviamo tutti gli elementi di testo vuoti
            final emptyTextElements = widget.selectedNote.noteElements
                .where((e) => e.type == "text" && e.content.trim().isEmpty)
                .toList();

            // Li rimuoviamo dalla nota prima di salvare
            for (var emptyElement in emptyTextElements) {
              widget.selectedNote.removeElement(emptyElement);
            }
            if (DiarySession.session.loggedDiary != null) {
              bool isTitleEmpty = widget.selectedNote.title.isEmpty;
              bool isBodyEmpty = widget.selectedNote.noteElements.isEmpty;
              if (isTitleEmpty && isBodyEmpty) {
                vm.deleteNote.run((
                  noteId: widget.selectedNote.id,
                  diary: DiarySession.session.loggedDiary!,
                ));
              } else {
                vm.saveNote.run((
                  note: widget.selectedNote,
                  diary: DiarySession.session.loggedDiary!,
                ));
              }
            }
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(
              context,
            ).unfocus(), // Rimuove il focus e chiude la tastiera
            child: Scaffold(
              appBar: AppBar(
                title: TextField(
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
              ),
              backgroundColor: Colors.teal.shade50,
              body: Column(
                children: <Widget>[
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
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 20,
                          child: Text(
                            "Creata il ${DateFormat(dayFormat).format(widget.selectedNote.creationDate)} alle ${DateFormat(timeFormat).format(widget.selectedNote.creationDate)}",
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
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
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
                onPressed: () => _showOptions(context),
                backgroundColor: Colors.teal,
                tooltip: 'Scegli un elemento da aggiungere alla nota',
                child: const Icon(
                  Icons.create_new_folder_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // Salva nota alla chiusura del BottomSheet
          ),
        );
      },
    );
  }
}
