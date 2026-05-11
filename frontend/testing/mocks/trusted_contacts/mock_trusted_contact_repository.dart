import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

class MockTrustedContactRepository extends Mock implements TrustedContactRepository {}

class FakeTrustedContact extends Fake implements TrustedContact {}

void registerTrustedContactFallbackValue() {
  registerFallbackValue(FakeTrustedContact());
}