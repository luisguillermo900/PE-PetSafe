import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evento_model.dart';

class CalendarioState {
  final List<EventoModel> eventos;
  final bool isLoading;

  CalendarioState({required this.eventos, this.isLoading = false});

  CalendarioState copyWith({
    List<EventoModel>? eventos,
    bool? isLoading,
  }) {
    return CalendarioState(
      eventos: eventos ?? this.eventos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalendarioViewModel extends StateNotifier<CalendarioState> {
  CalendarioViewModel() : super(CalendarioState(eventos: [])) {
    cargarEventos();
  }

  void cargarEventos() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500)); 
    state = state.copyWith(
      isLoading: false,
      eventos: [
        EventoModel(
          titulo: "Paseo",
          descripcion: "30 minutos en el parque",
          fecha: "28/05/2025",
        ),
        EventoModel(
          titulo: "Veterinario",
          descripcion: "Vacuna anual aplicada",
          fecha: "27/05/2025",
        ),
        EventoModel(
          titulo: "Alimentación",
          descripcion: "Comida especial para dieta",
          fecha: "26/05/2025",
        ),
        EventoModel(
          titulo: "Baño",
          descripcion: "Baño y corte de uñas",
          fecha: "25/05/2025",
        ),
      ],
    );
  }
}
