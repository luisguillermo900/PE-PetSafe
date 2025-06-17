import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class VentilacionState {
  final bool ventiladorActivo;
  final bool modoAutomatico;

  VentilacionState({
    required this.ventiladorActivo,
    required this.modoAutomatico,
  });

  VentilacionState copyWith({bool? ventiladorActivo, bool? modoAutomatico}) {
    return VentilacionState(
      ventiladorActivo: ventiladorActivo ?? this.ventiladorActivo,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class VentilacionViewModel extends StateNotifier<VentilacionState> {
  VentilacionViewModel()
    : super(VentilacionState(ventiladorActivo: false, modoAutomatico: false));

  final String _baseUrl = 'https://petsafe-78c00-default-rtdb.firebaseio.com';

  Future<void> toggleVentilador() async {
    final nuevoEstado = !state.ventiladorActivo;
    state = state.copyWith(
      ventiladorActivo: nuevoEstado,
      modoAutomatico: false,
    );

    final comando = {
      "accion": nuevoEstado ? "encender" : "apagar",
      "dispositivoId": "dispositivoIdActuador3",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> activarModoAutomatico() async {
    state = state.copyWith(modoAutomatico: true, ventiladorActivo: false);

    final comando = {
      "accion": "modo_automatico",
      "dispositivoId": "dispositivoIdActuador3",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> activarVentilador() async {
    state = state.copyWith(ventiladorActivo: true);
    final comando = {
      "accion": "encender",
      "dispositivoId": "dispositivoIdActuador3",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    await _enviarComandoAFirebase(comando);
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
