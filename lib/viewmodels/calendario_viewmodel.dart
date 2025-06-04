import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evento_model.dart';

class CalendarioState {
  final List<EventoModel> eventos;
  final bool isLoading;

  CalendarioState({required this.eventos, this.isLoading = false});
}

class CalendarioViewModel extends StateNotifier<CalendarioState> {
  CalendarioViewModel() : super(CalendarioState(eventos: [])) {
    cargarEventos();
  }

  void cargarEventos() {
    state = CalendarioState(isLoading: true, eventos: []);
    state = CalendarioState(
      isLoading: false,
      eventos: [
        EventoModel("Paseo", "30 minutos en el parque", "28/05/2025"),
        EventoModel("Veterinario", "Vacuna anual aplicada", "27/05/2025"),
        EventoModel("Alimentación", "Comida especial para dieta", "26/05/2025"),
        EventoModel("Baño", "Baño y corte de uñas", "25/05/2025"),
      ],
    );
  }
}
