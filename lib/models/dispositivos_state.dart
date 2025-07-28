class DispositivosState {
  final String idDispositivo;
  final String nombre;
  final String estado;
  final String modo;
  final String tiempo;
  final int timestamp;

  DispositivosState ({
    required this.idDispositivo,
    required this.nombre,
    required this.estado,
    required this.modo,
    required this.tiempo,
    required this.timestamp,
  });

  DispositivosState copyWith({
    String? idDispositivo,
    String? nombre,
    String? estado,
    String? modo,
    String? tiempo,
    int? timestamp,
  }) {
    return DispositivosState(
      idDispositivo: idDispositivo ?? this.idDispositivo,
      nombre: nombre ?? this.nombre,
      estado: estado ?? this.estado,
      modo: modo ?? this.modo,
      tiempo: tiempo ?? this.tiempo,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}