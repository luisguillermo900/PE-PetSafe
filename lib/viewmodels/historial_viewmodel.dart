import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/historial_model.dart';

class HistorialState {
  final List<HistorialItem> historial;
  final bool isLoading;

  HistorialState({
    required this.historial,
    required this.isLoading,
  });

  HistorialState copyWith({
    List<HistorialItem>? historial,
    bool? isLoading,
  }) {
    return HistorialState(
      historial: historial ?? this.historial,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HistorialViewModel extends StateNotifier<HistorialState> {
  HistorialViewModel()
      : super(HistorialState(historial: [], isLoading: false)) {
    cargarHistorial();
  }

  void cargarHistorial() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); 
    state = state.copyWith(
      historial: [
        HistorialItem(
            fecha: '28/05/2025',
            evento: 'Paseo',
            detalle: '30 minutos en el parque'),
        HistorialItem(
            fecha: '27/05/2025',
            evento: 'Veterinario',
            detalle: 'Vacuna anual aplicada'),
        HistorialItem(
            fecha: '26/05/2025',
            evento: 'Alimentación',
            detalle: 'Comida especial para dieta'),
        HistorialItem(
            fecha: '25/05/2025',
            evento: 'Baño',
            detalle: 'Baño y corte de uñas'),
      ],
      isLoading: false,
    );
  }

  void limpiarHistorial() {
    state = state.copyWith(historial: []);
  }
}