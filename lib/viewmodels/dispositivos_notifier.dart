import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab04/viewmodels/alertas_notifier.dart';
import '../models/dispositivos_state.dart';

class DispositivosNotifier extends StateNotifier<DispositivosState> {
  final AlertasNotifier alertasNotifier;
  DispositivosNotifier(this.alertasNotifier) : super(DispositivosState(
    idDispositivo: "",
    nombre: "",
    estado: "0",
    modo: "0",
    tiempo: "0",
    timestamp: 0,
    ));

  void procesarPayload(String mensajeJson) {
    final decoded = jsonDecode(mensajeJson);
    final nuevoIdDispositivo = decoded['id_dispositivo'];
    final nuevoNombre= decoded['dispositivo'];
    final nuevoEstado= decoded['estado'];
    final nuevoModo= decoded['modo'];
    final nuevoTiempo= decoded['tiempo'];
    final nuevaTimestamp = decoded['timestamp'];
    
    // Solo emitir nuevo estado si hay un cambio real
    if (state.idDispositivo != nuevoIdDispositivo ||
    state.nombre != nuevoNombre ||
    state.estado != nuevoEstado ||
    state.modo != nuevoModo ||
    state.tiempo != nuevoTiempo ||
    state.timestamp != nuevaTimestamp) {
      print("Emitiendo estado");
      final nuevoEstadoObj = state.copyWith(
        idDispositivo: nuevoIdDispositivo,
        nombre: nuevoNombre,
        estado: nuevoEstado,
        modo: nuevoModo,
        tiempo: nuevoTiempo,
        timestamp: nuevaTimestamp,
      );
      state = nuevoEstadoObj;
      print("Estado emitido");
      if (nuevoModo == 'automatico') {
        alertasNotifier.agregarAlerta(nuevoEstadoObj);
        print("Alerta guardada");
      }
    }
  }
}