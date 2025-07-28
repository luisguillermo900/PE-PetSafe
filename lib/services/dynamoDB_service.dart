import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dispositivos_state.dart';
import '../models/lectura_model.dart';

class DynamodbService {
  static const String _baseUrl = 'https://movfdks8jf.execute-api.us-east-2.amazonaws.com/prod';
  static Future<List<Lectura>> obtenerLecturas(String id, String fecha) async {
    final url = Uri.parse('$_baseUrl/lecturas?id=$id&fecha=$fecha');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final List<dynamic> data = json.decode(respuesta.body);
      return data.map<Lectura>((e) => Lectura.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener datos: ${respuesta.statusCode}');
    }
  }
  static Future<List<DispositivosState>> obtenerAlertas(String id, String fecha) async {
    final url = Uri.parse('$_baseUrl/alertas?id=$id&fecha=$fecha'); // Cambia según tu endpoint

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final alertas = <DispositivosState>[];
      for (final json in data) {
        final payload = json['payload'] ?? {};
        alertas.add(DispositivosState(
          idDispositivo: payload['id_dispositivo'] ?? '',
          nombre: payload['dispositivo'] ?? '',
          estado: payload['estado'] ?? '',
          modo: payload['modo'] ?? '',
          tiempo: payload['tiempo'] ?? '',
          timestamp: int.tryParse(payload['timestamp'].toString()) ?? 0,
        ));
      }
      print(alertas[0]);
      return alertas;
    } else {
      throw Exception('Error al obtener alertas: ${response.statusCode}');
    }
  }
}