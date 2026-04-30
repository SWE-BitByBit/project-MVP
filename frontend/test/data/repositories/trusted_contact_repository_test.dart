import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

import '../../../testing/mocks/trusted_contacts/mock_trusted_contact_service.dart';

void main() {
  late TrustedContactRepository repository;
  late MockTrustedContactService mockService;

  final List<Map<String, dynamic>> tContactsListJson = [
    {
      "contactId": "1",
      "name": "Mario Rossi",
      "email": "mario.rossi@example.com",
      "phoneNumber": "+393331234567"
    },
    {
      "contactId": "2",
      "name": "Giulia Bianchi",
      "email": "giulia.bianchi@example.com",
      "phoneNumber": "+393337654321"
    }
  ];

  final tContactJson = tContactsListJson.first;
  final tContactModel = TrustedContact(
    id: "1",
    name: "Mario Rossi",
    email: "mario.rossi@example.com",
    phoneNumber: "+393331234567",
  );

  setUp(() {
    mockService = MockTrustedContactService();
    repository = TrustedContactRepository(mockService);
    registerFallbackValue(tContactModel);
  });

  group('getContacts', () {
    test('should return list of contacts from service and cache them', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);

      final result = await repository.getContacts();

      expect(result.length, 2);
      expect(result.first.id, "1");
      expect(result.first.name, "Mario Rossi");
      verify(() => mockService.getContacts()).called(1);
    });

    test('should return cached contacts without calling service if cache is not empty', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();

      final result = await repository.getContacts();

      expect(result.length, 2);
      verify(() => mockService.getContacts()).called(1);
    });

    test('should call service when forceRefresh is true', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();

      await repository.getContacts(forceRefresh: true);

      verify(() => mockService.getContacts()).called(2);
    });
  });

  group('createContact', () {
    test('should call service and add new contact to cache', () async {
      repository.clearCache();
      when(() => mockService.addContact(any())).thenAnswer((_) async => tContactJson);

      final result = await repository.createContact(tContactModel);

      expect(result.id, "1");
      final list = await repository.getContacts();
      expect(list.any((c) => c.id == "1"), true);
      verify(() => mockService.addContact(any())).called(1);
    });
  });

  group('updateContact', () {
    test('should update contact in cache after service success', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();

      final updatedJson = {
        "contactId": "1",
        "name": "Mario Rossi Updated",
        "email": "mario.rossi@example.com",
        "phoneNumber": "+393331234567"
      };

      when(() => mockService.updateContact(any())).thenAnswer((_) async => updatedJson);

      final result = await repository.updateContact(tContactModel.copyWith(name: "Mario Rossi Updated"));

      expect(result.name, "Mario Rossi Updated");
      final list = await repository.getContacts();
      expect(list.firstWhere((c) => c.id == "1").name, "Mario Rossi Updated");
    });
  });

  group('deleteContact', () {
    test('should remove contact from cache if service success', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();
      when(() => mockService.deleteContact(any())).thenAnswer((_) async => {});

      await repository.deleteContact("1");

      final list = await repository.getContacts();
      expect(list.any((c) => c.id == "1"), false);
      verify(() => mockService.deleteContact("1")).called(1);
    });

    test('should rollback cache if service fails during deletion', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();
      when(() => mockService.deleteContact(any())).thenThrow(Exception("Network Error"));

      expect(() => repository.deleteContact("1"), throwsException);

      final list = await repository.getContacts();
      expect(list.any((c) => c.id == "1"), true);
    });
  });

  group('sendSosAlert', () {
    test('should call service sendSosAlert', () async {
      when(() => mockService.sendSosAlert()).thenAnswer((_) async => {});

      await repository.sendSosAlert();

      verify(() => mockService.sendSosAlert()).called(1);
    });
  });

  group('clearCache', () {
    test('should empty the local cache', () async {
      when(() => mockService.getContacts()).thenAnswer((_) async => tContactsListJson);
      await repository.getContacts();

      repository.clearCache();

      await repository.getContacts();
      verify(() => mockService.getContacts()).called(2);
    });
  });
}