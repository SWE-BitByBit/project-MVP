import 'dart:io';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/note.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_view_model.dart';

class MockDiaryViewModel extends Mock implements DiaryViewModel {}

// Mock per il comando di salvataggio: Command<Param, Result>
class MockSaveNoteCommand extends Mock
    implements Command<({Note note, DiaryType diary}), void> {}

// Mock per il comando di eliminazione: Command<Param, Result>
class MockDeleteNoteCommand extends Mock
    implements Command<({String noteId, DiaryType diary}), void> {}

class MockUpdateTitleCommand extends Mock
    implements Command<({String newTitle, DiaryType diary}), void> {}

class MockAddElementCommand extends Mock
    implements Command<({String type, String? text, File? file, DiaryType diary}), void> {}