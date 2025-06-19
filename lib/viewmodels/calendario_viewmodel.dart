import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/evento_model.dart';

class CalendarioState {
  final List<EventoModel> eventos;
  final bool isLoading;
  final DateTime selectedDay;

  CalendarioState({
    required this.eventos,
    this.isLoading = false,
    required this.selectedDay,
  });

  CalendarioState copyWith({
    List<EventoModel>? eventos,
    bool? isLoading,
    DateTime? selectedDay,
  }) {
    return CalendarioState(
      eventos: eventos ?? this.eventos,
      isLoading: isLoading ?? this.isLoading,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

class CalendarioViewModel extends StateNotifier<CalendarioState> {
  CalendarioViewModel()
    : super(CalendarioState(eventos: [], selectedDay: DateTime.now())) {
    cargarEventos();
  }

  final String _baseUrl = 'https://petsafe-78c00-default-rtdb.firebaseio.com';

  Future<void> cargarEventos() async {
    state = state.copyWith(isLoading: true);
    final response = await http.get(Uri.parse('$_baseUrl/eventos.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final eventos =
          data.entries.map((e) {
            return EventoModel.fromMap(e.key, e.value);
          }).toList();

      state = state.copyWith(eventos: eventos, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> agregarEvento({
    required String titulo,
    required String descripcion,
    required String fecha,
  }) async {
    final timestamp = DateTime.parse(fecha).millisecondsSinceEpoch;

    final nuevoEvento = {
      "titulo": titulo,
      "descripcion": descripcion,
      "fecha": fecha,
      "timestamp": timestamp,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/eventos.json'),
      body: json.encode(nuevoEvento),
    );

    if (response.statusCode == 200) {
      cargarEventos();
    }
  }

  Future<void> editarEvento({
    required String id,
    required String descripcion,
    required String fecha,
  }) async {
    final timestamp = DateTime.parse(fecha).millisecondsSinceEpoch;

    final actualizado = {
      "descripcion": descripcion,
      "fecha": fecha,
      "timestamp": timestamp,
    };

    await http.patch(
      Uri.parse('$_baseUrl/eventos/$id.json'),
      body: json.encode(actualizado),
    );

    cargarEventos();
  }

  void seleccionarDia(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  List<EventoModel> obtenerEventosDelDia(DateTime dia) {
    return state.eventos.where((evento) {
      final fechaEvento = DateTime.parse(evento.fecha);
      return fechaEvento.year == dia.year &&
          fechaEvento.month == dia.month &&
          fechaEvento.day == dia.day;
    }).toList();
  }
}
