import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class IluminacionState {
  final bool luzActiva;
  final bool modoAutomatico;

  IluminacionState({required this.luzActiva, required this.modoAutomatico});

  IluminacionState copyWith({bool? luzActiva, bool? modoAutomatico}) {
    return IluminacionState(
      luzActiva: luzActiva ?? this.luzActiva,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class IluminacionViewModel extends StateNotifier<IluminacionState> {
  IluminacionViewModel()
    : super(IluminacionState(luzActiva: false, modoAutomatico: false));

  final String _baseUrl = 'https://petsafe-78c00-default-rtdb.firebaseio.com';

  Future<void> toggleLuz() async {
    final nuevaLuz = !state.luzActiva;
    state = state.copyWith(luzActiva: nuevaLuz, modoAutomatico: false);

    final comando = {
      "accion": nuevaLuz ? "encender" : "apagar",
      "dispositivoId": "dispositivoIdActuador1",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> activarModoAutomatico() async {
    state = state.copyWith(modoAutomatico: true, luzActiva: false);

    final comando = {
      "accion": "modo_automatico",
      "dispositivoId": "dispositivoIdActuador1",
      "ejecutadoPor": "usuarioId1",
      "estado": "pendiente",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    await _enviarComandoAFirebase(comando);
  }

  Future<void> activarLuz() async {
    state = state.copyWith(luzActiva: true);
    final comando = {
      "accion": "encender",
      "dispositivoId": "dispositivoIdActuador1",
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
