import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dynamoDB_service.dart';
import '../models/dispositivos_state.dart';

class AlertasNotifier extends StateNotifier<List<DispositivosState>> {
  final DynamodbService servicio;

  AlertasNotifier(this.servicio) : super([]) {}

  Future<void> cargarAlertas() async {
    DateTime hoy = DateTime.now();
    String fechaFormateada = DateFormat('dd/MM/yy').format(hoy);
    state = await DynamodbService.obtenerAlertas("esp32-01",fechaFormateada);
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