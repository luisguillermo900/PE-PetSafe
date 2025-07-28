import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dynamoDB_service.dart';
import '../models/dispositivos_state.dart';

class AlertasNotifier extends StateNotifier<List<DispositivosState>> {
  final DynamodbService servicio;

  AlertasNotifier(this.servicio) : super([]) {}

  Future<void> cargarAlertas() async {
    state = await DynamodbService.obtenerAlertas("esp32-01","28/07/25");
    print("Alertas cargadas");
    print('Lista: $state');
  }

  void agregarAlerta(DispositivosState alerta) {
    state = [...state, alerta];
  }

  List<DispositivosState> obtenerAlertasPorDispositivo(String dispositivo) {
    return state.where((alerta) => alerta.nombre == dispositivo).toList();
  }

  void limpiarAlertas() {
    state = [];
  }
}