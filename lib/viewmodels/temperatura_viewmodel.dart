import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class TemperaturaState {
  final int temperatura;
  final int humedad;
  final bool calefaccionActiva;
  final bool modoAutomatico;

  TemperaturaState({
    required this.temperatura,
    required this.humedad,
    required this.calefaccionActiva,
    required this.modoAutomatico,
  });

  TemperaturaState copyWith({
    int? temperatura,
    int? humedad,
    bool? calefaccionActiva,
    bool? modoAutomatico,
  }) {
    return TemperaturaState(
      temperatura: temperatura ?? this.temperatura,
      humedad: humedad ?? this.humedad,
      calefaccionActiva: calefaccionActiva ?? this.calefaccionActiva,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class TemperaturaViewModel extends StateNotifier<TemperaturaState> {
  TemperaturaViewModel()
    : super(
        TemperaturaState(
          temperatura: 20,
          humedad: 60,
          calefaccionActiva: false,
          modoAutomatico: false,
        ),
      );

  final String _baseUrl = 'https://petsafe-78c00-default-rtdb.firebaseio.com';

  Future<void> toggleCalefaccion() async {
    final nuevoEstado = !state.calefaccionActiva;
    state = state.copyWith(
      calefaccionActiva: nuevoEstado,
      modoAutomatico: false,
    );

    final comando = {
      "accion": nuevoEstado ? "encender" : "apagar",
      "dispositivoId": "dispositivoIdActuador2",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> activarModoAutomatico() async {
    state = state.copyWith(
      modoAutomatico: true,
      calefaccionActiva: false,
      temperatura: 28,
    );

    final comando = {
      "accion": "modo_automatico",
      "dispositivoId": "dispositivoIdActuador2",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> actualizarTemperatura(int nuevaTemp) async {
    state = state.copyWith(temperatura: nuevaTemp);
  }

  Future<void> actualizarHumedad(int nuevaHumedad) async {
    state = state.copyWith(humedad: nuevaHumedad);
  }

  Future<void> _enviarComandoAFirebase(Map<String, dynamic> comando) async {
    final url = Uri.parse('$_baseUrl/comandosActuadores.json');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(comando),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo guardar el comando en Firebase');
    }
  }
}
