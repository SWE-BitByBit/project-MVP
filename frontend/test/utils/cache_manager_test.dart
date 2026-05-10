import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/cache_manager.dart';

import '../../testing/mocks/core/mock_cacheable_repository.dart';

void main() {
  group('CacheManager', () {
    late CacheManager cacheManager;
    late MockCacheableRepository mockRepo1;
    late MockCacheableRepository mockRepo2;
    late MockCacheableRepository mockRepo3;

    setUp(() {
      mockRepo1 = MockCacheableRepository();
      mockRepo2 = MockCacheableRepository();
      mockRepo3 = MockCacheableRepository();

      cacheManager = CacheManager([
        mockRepo1,
        mockRepo2,
        mockRepo3,
      ]);
    });

    test('clearAllCaches dovrebbe chiamare clearCache su tutti i repository registrati', () {
      // act
      cacheManager.clearAllCaches();

      // assert
      verify(() => mockRepo1.clearCache()).called(1);
      verify(() => mockRepo2.clearCache()).called(1);
      verify(() => mockRepo3.clearCache()).called(1);
    });

    test('clearAllCaches non dovrebbe fare nulla se la lista è vuota', () {
      // arrange
      final emptyCacheManager = CacheManager([]);

      // act & assert
      // Non ci aspettiamo eccezioni
      expect(() => emptyCacheManager.clearAllCaches(), returnsNormally);
    });
  });
}