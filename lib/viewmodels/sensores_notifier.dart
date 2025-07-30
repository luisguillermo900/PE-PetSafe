import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SensoresState {
  final String temperatura;
  final String humedad;
  final String iluminancia;
  //final String dispositivo;
  //final String estado;
  //final String modo;
  //final String tiempo;

  SensoresState({
    required this.temperatura,
    required this.humedad,
    required this.iluminancia,
  });

  SensoresState copyWith({
    String? temperatura,
    String? humedad,
    String? iluminancia,
  }) {
    return SensoresState(
      temperatura: temperatura ?? this.temperatura,
      humedad: humedad ?? this.humedad,
      iluminancia: iluminancia ?? this.iluminancia,
    );
  }
}

class SensoresNotifier extends StateNotifier<SensoresState> {
  SensoresNotifier() : super(SensoresState(temperatura: "0", humedad: "0", iluminancia: "0"));

  void procesarPayload(String mensajeJson) {
    final decoded = jsonDecode(mensajeJson);
    String nuevaTemperatura = decoded['temperatura']?.toString() ?? '0';
    String nuevaHumedad = decoded['humedad']?.toString() ?? '0';
    String nuevaIluminancia = decoded['iluminancia']?.toString() ?? '0';
    
    nuevaTemperatura = nuevaTemperatura.length >=2 ? nuevaTemperatura.substring(0,2) : '0';
    nuevaHumedad = nuevaHumedad.length >=2 ? nuevaHumedad.substring(0,2) : '0';

    // Solo emitir nuevo estado si hay un cambio real
    if (state.temperatura != nuevaTemperatura ||
    state.humedad != nuevaHumedad ||
    state.iluminancia != nuevaIluminancia) {  
      state = state.copyWith(
        temperatura: nuevaTemperatura,
        humedad: nuevaHumedad,
        iluminancia: nuevaIluminancia,
      );
    }
  }
}