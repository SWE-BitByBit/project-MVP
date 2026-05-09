
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

// --- MOCKS ---
class MockTrustedContactViewModel extends Mock implements TrustedContactViewModel {}
class MockCommandLoad extends Mock implements Command<void, void> {}
class MockCommandDelete extends Mock implements Command<String, void> {}
class MockCommandCreate extends Mock implements Command<TrustedContact, void> {}
class MockCommandUpdate extends Mock implements Command<TrustedContact, void> {}
