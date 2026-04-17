import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servizio responsabile del recupero dei materiali informativi dalla sorgente dati.
///
/// Attualmente simula una chiamata di rete restituendo dati statici. In futuro,
/// questa classe gestirà le chiamate HTTP o le query ad AWS Cognito/DynamoDB.
class MaterialService {
  final String _apiUrl =
      'https://6zkvgiq4k4.execute-api.eu-south-1.amazonaws.com/dev/materials';

  /// Recupera una lista grezza di materiali informativi.
  ///
  /// Simula un ritardo di rete di 1 secondo per testare le animazioni di
  /// caricamento nella UI, e restituisce una lista di mappe JSON.
  Future<List<Map<String, dynamic>>> fetchMaterials() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);

        return decodedData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Errore del server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossibile connettersi ad AWS: $e');
    }
  }
}
