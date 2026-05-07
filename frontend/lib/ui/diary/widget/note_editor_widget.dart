import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note_element.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_audio_player_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/options_menu_widget.dart';

/// Widget che gestisce la modifica delle note (Completamente Reattivo)
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
  late final FocusNode _titleFocusNode;
  final _imagePicker = ImagePicker();

  final String dayFormat = "d/M/y";
  final String timeFormat = "H:mm";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.selectedNote.title);
    _titleFocusNode = FocusNode();

    // Quando l'utente finisce di digitare il titolo e toglie il focus, inviamo l'update al ViewModel
    _titleFocusNode.addListener(() {
      if (!_titleFocusNode.hasFocus) {
        final newTitle = _titleController.text.trim();
        if (newTitle != widget.selectedNote.title) {
          context.read<DiaryViewModel>().updateTitle.run((
          newTitle: newTitle,
          diary: DiarySession.session.loggedDiary!,
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addNewElement(String type) async {
    File? pickedFile;

    if (type == 'image') {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      pickedFile = File(image.path);
    } else if (type == 'audio') {
      final pickResult = await FilePicker.pickFiles(type: FileType.audio);
      if (pickResult == null) return;
      pickedFile = File(pickResult.files.single.path!);
    }

    if (!mounted) return;

    // Richiamiamo il comando granulare: l'UI si aggiornerà in automatico tramite il Consumer!
    context.read<DiaryViewModel>().addElement.run((
    type: type,
    text: type == 'text' ? "" : null,
    file: pickedFile,
    diary: DiarySession.session.loggedDiary!
    ));
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
        if (value == 'delete') onDelete();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryViewModel>(
      builder: (context, vm, child) {
        final currentNote = vm.currentNote;
        if (currentNote == null) return const SizedBox.shrink();

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            // Rimuoviamo il focus per innescare gli ultimi salvataggi pendenti (titolo o testo)
            FocusScope.of(context).unfocus();

            // Pulizia sicura degli elementi di testo vuoti prima di chiudere
            final emptyTextElements = currentNote.noteElements
                .where((e) => e.type == "text" && e.content.trim().isEmpty)
                .toList();

            for (var emptyElement in emptyTextElements) {
              vm.deleteElement.run(emptyElement);
            }

            // Nessun save globale! Svuotiamo solo lo stato locale del VM.
            vm.clearCurrentNote();
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  maxLines: null,
                  maxLength: 64,
                  decoration: const InputDecoration(
                    hintText: 'Titolo nota',
                    hintStyle: TextStyle(color: Colors.black45),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),
              backgroundColor: Colors.teal.shade50,
              body: Column(
                children: [
                  Container(
                    width: double.infinity, // <-- 1. Forza il container a prendere tutto lo schermo
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    color: const Color.fromARGB(255, 201, 233, 232),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // <-- 2. Centra i figli orizzontalmente
                      children: [
                        Text(
                          "Creata il ${DateFormat(dayFormat).format(currentNote.creationDate)} alle ${DateFormat(timeFormat).format(currentNote.creationDate)}",
                          textAlign: TextAlign.center, // <-- 3. Centra il testo multiriga
                          style: TextStyle(color: Colors.teal.shade900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ultima modifica: ${DateFormat(dayFormat).format(currentNote.updateDate)} alle ${DateFormat(timeFormat).format(currentNote.updateDate)}",
                          textAlign: TextAlign.center, // <-- 3. Centra il testo multiriga
                          style: TextStyle(color: Colors.teal.shade900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: currentNote.noteElements.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: currentNote.noteElements.length,
                      itemBuilder: (context, index) {
                        final element = currentNote.noteElements[index];
                        return _buildCardForElement(element, vm);
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                elevation: 10,
                onPressed: () => _showOptions(context),
                backgroundColor: Colors.teal,
                tooltip: 'Scegli un elemento',
                child: const Icon(Icons.create_new_folder_outlined, color: Colors.white, size: 28),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Metodo helper che smista la costruzione della UI a seconda del tipo di elemento
  Widget _buildCardForElement(NoteElement element, DiaryViewModel vm) {
    if (element.type == 'text') {
      return _TextElementCard(
        element: element,
        onDelete: () => vm.deleteElement.run(element),
      );
    }

    // Per Immagini e Audio la UI non ha stato locale complesso, possiamo istanziarla direttamente
    Widget mediaContent;
    if (element.type == 'image') {
      mediaContent = ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.file(element.mediaFile!),
      );
    } else {
      mediaContent = NoteAudioPlayerWidget(
        onDismiss: () {},
        trackUrl: element.mediaFile!.path,
      );
    }

    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40, top: 8, left: 8, bottom: 8),
            child: mediaContent,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _deleteCardOptionMenu(() => vm.deleteElement.run(element)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center( // <-- 1. Avvolge tutto per centrare la colonna nello spazio a disposizione
      child: Transform.translate(
        offset: const Offset(0, -28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // <-- 2. Centra gli elementi
            children: [
              Icon(Icons.edit, size: 64, color: Colors.teal.shade200),
              const SizedBox(height: 16),
              const Text(
                "Questa nota è vuota",
                textAlign: TextAlign.center, // <-- 3. Centra il testo
                style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 89, 95, 95),
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aggiungi un elemento con il pulsante qui sotto.',
                textAlign: TextAlign.center, // <-- 3. Centra il testo
                style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 135, 141, 141)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) async {
    showMenu(
      position: const RelativeRect.fromLTRB(100, 1000, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          onTap: () => _addNewElement('text'),
          child: const Row(children: [Icon(Icons.textsms), SizedBox(width: 10), Expanded(child: Text("Aggiungi testo"))]),
        ),
        PopupMenuItem(
          onTap: () => _addNewElement('image'),
          child: const Row(children: [Icon(Icons.photo), SizedBox(width: 10), Expanded(child: Text("Aggiungi immagine"))]),
        ),
        PopupMenuItem(
          onTap: () => _addNewElement('audio'),
          child: const Row(children: [Icon(Icons.multitrack_audio), SizedBox(width: 10), Expanded(child: Text("Aggiungi traccia audio"))]),
        ),
      ],
    );
  }
}

/// Sotto-widget dedicato esplicitamente alla gestione del focus e del testo.
/// Isola la logica del TextField per evitare che la ListView "ricicli" in modo errato i controller.
class _TextElementCard extends StatefulWidget {
  final NoteElement element;
  final VoidCallback onDelete;

  const _TextElementCard({required this.element, required this.onDelete});

  @override
  State<_TextElementCard> createState() => _TextElementCardState();
}

class _TextElementCardState extends State<_TextElementCard> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.element.content);
    _focusNode = FocusNode();

    // Se stiamo creando un nuovo elemento vuoto, apriamo la tastiera in automatico
    if (widget.element.content.isEmpty) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _focusNode.requestFocus();
      });
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_controller.text != widget.element.content) {
          context.read<DiaryViewModel>().editElementText.run((
          element: widget.element,
          newText: _controller.text,
          diary: DiarySession.session.loggedDiary! // <-- Aggiungi questa riga
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40, top: 8, left: 8, bottom: 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: OptionsMenu<String>(
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
                if (value == 'delete') widget.onDelete();
              },
            ),
          ),
        ],
      ),
    );
  }
}