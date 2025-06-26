class EventoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final int timestamp;

  EventoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.timestamp,
  });

  factory EventoModel.fromMap(String id, Map<String, dynamic> data) {
    return EventoModel(
      id: id,
      titulo: data['titulo'],
      descripcion: data['descripcion'],
      fecha: data['fecha'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
      'timestamp': timestamp,
    };
  }
}
