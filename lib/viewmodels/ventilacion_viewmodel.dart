import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentilacionState {
  final bool ventiladorActivo;
  final bool modoAutomatico;

  VentilacionState({
    required this.ventiladorActivo,
    required this.modoAutomatico,
  });

  VentilacionState copyWith({bool? ventiladorActivo, bool? modoAutomatico}) {
    return VentilacionState(
      ventiladorActivo: ventiladorActivo ?? this.ventiladorActivo,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class VentilacionViewModel extends StateNotifier<VentilacionState> {
  VentilacionViewModel()
    : super(VentilacionState(ventiladorActivo: false, modoAutomatico: false));

  void toggleVentilador() {
    state = state.copyWith(
      ventiladorActivo: !state.ventiladorActivo,
      modoAutomatico: false,
    );
  }

  void activarModoAutomatico() {
    state = state.copyWith(modoAutomatico: true, ventiladorActivo: false);
  }

  void activarVentilador() {
    state = state.copyWith(ventiladorActivo: true);
  }
}
