import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemperaturaState {
  final int temperatura;
  final int humedad;
  final bool calefaccionActiva;
  final bool modoAutomatico;

  TemperaturaState({
    required this.temperatura,
    required this.humedad,
    required this.calefaccionActiva,
    required this.modoAutomatico,
  });

  TemperaturaState copyWith({
    int? temperatura,
    int? humedad,
    bool? calefaccionActiva,
    bool? modoAutomatico,
  }) {
    return TemperaturaState(
      temperatura: temperatura ?? this.temperatura,
      humedad: humedad ?? this.humedad,
      calefaccionActiva: calefaccionActiva ?? this.calefaccionActiva,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class TemperaturaViewModel extends StateNotifier<TemperaturaState> {
  TemperaturaViewModel()
    : super(
        TemperaturaState(
          temperatura: 25,
          humedad: 60,
          calefaccionActiva: false,
          modoAutomatico: false,
        ),
      );

  void toggleCalefaccion() {
    state = state.copyWith(
      calefaccionActiva: !state.calefaccionActiva,
      modoAutomatico: false,
    );
  }

  void activarModoAutomatico() {
    state = state.copyWith(
      modoAutomatico: true,
      calefaccionActiva: false,
      temperatura: 28,
    );
  }

  void actualizarTemperatura(int nuevaTemp) {
    state = state.copyWith(temperatura: nuevaTemp);
  }

  void actualizarHumedad(int nuevaHumedad) {
    state = state.copyWith(humedad: nuevaHumedad);
  }
}
