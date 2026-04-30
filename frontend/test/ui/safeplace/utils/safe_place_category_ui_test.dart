import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/utils/safe_place_category_ui.dart';

void main() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blue,
    onPrimary: Colors.white,
    secondary: Colors.green,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    tertiaryContainer: Colors.yellow,
    outline: Colors.grey,
    onSurfaceVariant: Colors.black54,
  );

  group('SafePlaceCategoryUI Extension Tests', () {
    test('hospital dovrebbe restituire icona local_hospital e colore error', () {
      const category = SafePlaceCategory.hospital;
      expect(category.icon, Icons.local_hospital);
      expect(category.getColor(scheme), scheme.error);
    });

    test('police dovrebbe restituire icona local_police e colore primary', () {
      const category = SafePlaceCategory.police;
      expect(category.icon, Icons.local_police);
      expect(category.getColor(scheme), scheme.primary);
    });

    test('pharmacy dovrebbe restituire icona local_pharmacy e colore tertiaryContainer', () {
      const category = SafePlaceCategory.pharmacy;
      expect(category.icon, Icons.local_pharmacy);
      expect(category.getColor(scheme), scheme.tertiaryContainer);
    });
  });
}