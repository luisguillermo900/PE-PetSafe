import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static const String baseUrl =
      'https://petsafe-78c00-default-rtdb.firebaseio.com';

  /// Obtener lista de alertas activas desde Firebase
  static Future<List<Map<String, dynamic>>> fetchAlertas() async {
    final response = await http.get(Uri.parse('$baseUrl/alertas.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries.map((e) {
        final value = e.value as Map<String, dynamic>;
        return {
          'mensaje': value['mensaje'],
          'tipo': value['tipo'],
          'estado': value['estado'],
          'valorMedido': value['valorMedido'],
          'timestamp': value['timestamp'],
        };
      }).toList();
    } else {
      throw Exception('No se pudieron cargar las alertas.');
    }
  }

  /// Obtener historial de iluminación desde comandosActuadores
  static Future<List<Map<String, dynamic>>> fetchHistorialIluminacion() async {
    final response = await http.get(
      Uri.parse('$baseUrl/comandosActuadores.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries.map((e) {
        final value = e.value as Map<String, dynamic>;
        return {
          'accion': value['accion'],
          'estado': value['estado'],
          'dispositivoId': value['dispositivoId'],
          'ejecutadoPor': value['ejecutadoPor'],
          'timestamp': value['timestamp'],
        };
      }).toList();
    } else {
      throw Exception('No se pudo cargar el historial de iluminación.');
    }
  }

  /// Obtener historial de temperatura y humedad desde lecturasSensores
  static Future<List<Map<String, dynamic>>> fetchHistorialTemperatura() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturasSensores.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<Map<String, dynamic>> historial = [];

      for (final sensorEntry in data.entries) {
        final lecturas = sensorEntry.value as Map<String, dynamic>;
        for (final lecturaEntry in lecturas.entries) {
          final valores = lecturaEntry.value as Map<String, dynamic>;
          historial.add({
            'temperatura': valores['temperatura'],
            'humedad': valores['humedad'],
            'timestamp': valores['timestamp'],
          });
        }
      }

      return historial;
    } else {
      throw Exception('No se pudo cargar el historial de temperatura.');
    }
  }

  /// Obtener historial de ventilación desde comandosActuadores
  static Future<List<Map<String, dynamic>>> fetchHistorialVentilacion() async {
    final response = await http.get(
      Uri.parse('$baseUrl/comandosActuadores.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.entries
          .map((e) {
            final value = e.value as Map<String, dynamic>;
            return {
              'accion': value['accion'],
              'estado': value['estado'],
              'dispositivoId': value['dispositivoId'],
              'ejecutadoPor': value['ejecutadoPor'],
              'timestamp': value['timestamp'],
            };
          })
          .where(
            (e) =>
                e['dispositivoId'] != null &&
                e['dispositivoId'].toString().contains('Actuador'),
          )
          .toList();
    } else {
      throw Exception('No se pudo cargar el historial de ventilación.');
    }
  }
}
