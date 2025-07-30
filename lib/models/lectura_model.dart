class Lectura {
  final String idDispositivo;
  final double iluminancia;
  final double temperatura;
  final double humedad;
  final String tiempo;
  final int timestamp;

  Lectura({
    required this.idDispositivo,
    required this.iluminancia,
    required this.temperatura,
    required this.humedad,
    required this.tiempo,
    required this.timestamp,
  });

  factory Lectura.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] ?? {};
    print('Lectura:  $payload');
    return Lectura(
      idDispositivo: payload['id_dispositivo'] ?? '',
      iluminancia: double.tryParse(payload['iluminancia'].toString()) ?? 0,
      temperatura: double.tryParse(payload['temperatura'].toString()) ?? 0,
      humedad: double.tryParse(payload['humedad'].toString()) ?? 0,
      tiempo: payload['tiempo'] ?? '',
      timestamp: int.tryParse(payload['timestamp'].toString()) ?? 0,
    );
  }
}