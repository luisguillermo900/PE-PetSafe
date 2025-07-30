import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lab04/models/lectura_model.dart';
import 'package:lab04/services/dynamoDB_service.dart';

class LecturasNotifier extends StateNotifier<List<Lectura>> {
  final DynamodbService servicio;
  LecturasNotifier(this.servicio) : super([]) {}
  
  Future<void> cargarLecturas() async {
    DateTime hoy = DateTime.now();
    String fechaFormateada = DateFormat('dd/MM/yy').format(hoy);
    state = await DynamodbService.obtenerLecturas("esp32-01",fechaFormateada); //fechaFormateada
    print("Lecturas cargadas");
    print('Lista: $state');
  }
}