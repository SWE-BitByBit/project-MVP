import 'package:mvp_app_protegge_e_trasforma/data/repositories/material_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/resource_type.dart';

class MockMaterialRepository implements MaterialRepository {
  bool shouldThrowError = false;
  bool shouldWait = false;
  List<Resource> mockedMaterials = [
    Resource(
      id: '1',
      title: 'Law Resource',
      content: 'Content 1',
      type: ResourceType.law,
    ),
    Resource(
      id: '2',
      title: 'Community Resource',
      content: 'Content 2',
      url: 'https://community.org',
      type: ResourceType.community,
    ),
    Resource(
      id: '3',
      title: 'Article Resource',
      content: 'Content 3',
      type: ResourceType.article,
    ),
  ];

  @override
  Future<List<Resource>> getMaterials() async {
    if (shouldWait) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (shouldThrowError) {
      throw Exception('Repository error');
    }
    return mockedMaterials;
  }
}
