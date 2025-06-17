import 'package:flutter_riverpod/flutter_riverpod.dart';

class IluminacionState {
  final bool luzActiva;
  final bool modoAutomatico;

  IluminacionState({required this.luzActiva, required this.modoAutomatico});

  IluminacionState copyWith({bool? luzActiva, bool? modoAutomatico}) {
    return IluminacionState(
      luzActiva: luzActiva ?? this.luzActiva,
      modoAutomatico: modoAutomatico ?? this.modoAutomatico,
    );
  }
}

class IluminacionViewModel extends StateNotifier<IluminacionState> {
  IluminacionViewModel()
    : super(IluminacionState(luzActiva: false, modoAutomatico: false));

  void toggleLuz() {
    state = state.copyWith(luzActiva: !state.luzActiva, modoAutomatico: false);
  }

  void activarModoAutomatico() {
    state = state.copyWith(modoAutomatico: true, luzActiva: false);
  }

  void activarLuz() {
    state = state.copyWith(luzActiva: true);
  }
}
