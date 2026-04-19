import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servizio responsabile del recupero dei materiali informativi tramite chiamata API.
///
/// Gestisce le richieste HTTP verso l'endpoint AWS Lambda configurato.
class MaterialService {
  final String _apiUrl =
      'https://6zkvgiq4k4.execute-api.eu-south-1.amazonaws.com/dev/materials';

  /// Effettua una richiesta GET per recuperare la lista dei materiali.
  ///
  /// Restituisce una lista di mappe JSON decodificate dal corpo della risposta.
  /// Solleva un'eccezione in caso di errore di rete o risposta non valida dal server.
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
