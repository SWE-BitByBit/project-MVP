import 'package:mvp_app_protegge_e_trasforma/data/services/material_service.dart';

class MockMaterialService implements MaterialService {
  bool shouldThrowError = false;
  List<Map<String, dynamic>> mockedData = [
    {
      'resource_id': '1',
      'title': 'Test Law',
      'content': 'Test Content',
      'url': null,
      'type': 'LAW',
    },
    {
      'resource_id': '2',
      'title': 'Test Community',
      'content': 'Test Community Content',
      'url': 'https://test.com',
      'type': 'COMMUNITY',
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    if (shouldThrowError) {
      throw Exception('Network error');
    }
    return mockedData;
  }
}
