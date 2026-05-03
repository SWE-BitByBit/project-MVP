import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/trusted_contact_service.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late TrustedContactService service;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    service = TrustedContactService(apiClient: mockApiClient);
  });

  final List<dynamic> tContactsJsonList = [
    {
      "contactId": "1",
      "name": "Mario Rossi",
      "email": "mario.rossi@example.com",
      "phoneNumber": "+393331234567",
    },
    {
      "contactId": "2",
      "name": "Giulia Bianchi",
      "email": "giulia.bianchi@example.com",
      "phoneNumber": "+393337654321",
    },
  ];

  final tContactData = {
    "contactId": "1",
    "name": "Mario Rossi",
    "email": "mario.rossi@example.com",
    "phoneNumber": "+393331234567",
  };

  final Map<String, dynamic> tPosition = {
    "latitude": 45.4642,
    "longitude": 9.1900,
  };

  group('getContacts', () {
    test(
      'should perform GET request on /trusted_contact and return a list of maps',
      () async {
        // arrange
        when(
          () => mockApiClient.get(any()),
        ).thenAnswer((_) async => tContactsJsonList);

        // act
        final result = await service.getContacts();

        // assert
        expect(result, equals(tContactsJsonList));
        verify(() => mockApiClient.get('/trusted_contact')).called(1);
      },
    );

    test(
      'should return empty list if ApiClient returns something that is not a List',
      () async {
        // arrange
        when(
          () => mockApiClient.get(any()),
        ).thenAnswer((_) async => {'error': 'not a list'});

        // act
        final result = await service.getContacts();

        // assert
        expect(result, isEmpty);
      },
    );
  });

  group('addContact', () {
    test(
      'should perform POST request on /trusted_contact with correct body',
      () async {
        // arrange
        when(
          () => mockApiClient.post(any(), body: any(named: 'body')),
        ).thenAnswer((_) async => tContactData);

        // act
        final result = await service.addContact(tContactData);

        // assert
        expect(result, equals(tContactData));
        verify(
          () => mockApiClient.post('/trusted_contact', body: tContactData),
        ).called(1);
      },
    );
  });

  group('updateContact', () {
    test(
      'should perform PUT request on /trusted_contact/{id} with correct body',
      () async {
        // arrange
        const tId = "1";
        when(
          () => mockApiClient.put(any(), body: any(named: 'body')),
        ).thenAnswer((_) async => tContactData);

        // act
        final result = await service.updateContact(tContactData);

        // assert
        expect(result, equals(tContactData));
        verify(
          () => mockApiClient.put('/trusted_contact/$tId', body: tContactData),
        ).called(1);
      },
    );
  });

  group('deleteContact', () {
    test('should perform DELETE request on /trusted_contact/{id}', () async {
      // arrange
      const tId = "1";
      when(() => mockApiClient.delete(any())).thenAnswer((_) async => {});

      // act
      await service.deleteContact(tId);

      // assert
      verify(() => mockApiClient.delete('/trusted_contact/$tId')).called(1);
    });
  });

  group('sendSosAlert', () {
    test('should perform PUT request on /alert', () async {
      // arrange
      when(
        () => mockApiClient.put(any(), body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      // act
      await service.sendSosAlert(tPosition);

      // assert
      verify(() => mockApiClient.put('/alert', body: tPosition)).called(1);
    });
  });
}
