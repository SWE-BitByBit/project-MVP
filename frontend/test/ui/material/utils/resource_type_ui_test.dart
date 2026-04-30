import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/utils/resource_type_ui.dart';

void main() {
  // Mock del ColorScheme per verificare i mapping dei colori
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
    tertiaryContainer: Colors.orange,
    outline: Colors.grey,
  );

  group('ResourceTypeUI Extension - Mapping UI', () {
    test('community: deve restituire icona people_alt e colore tertiaryContainer', () {
      const type = ResourceType.community;
      expect(type.icon, Icons.people_alt_outlined);
      expect(type.getColor(scheme), scheme.tertiaryContainer);
    });

    test('law: deve restituire icona gavel e colore primary', () {
      const type = ResourceType.law;
      expect(type.icon, Icons.gavel);
      expect(type.getColor(scheme), scheme.primary);
    });

    test('article: deve restituire icona article_outlined e colore outline', () {
      const type = ResourceType.article;
      expect(type.icon, Icons.article_outlined);
      expect(type.getColor(scheme), scheme.outline);
    });
  });
}