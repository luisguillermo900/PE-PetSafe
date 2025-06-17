import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../services/firebase_service.dart';

class VentilacionView extends ConsumerWidget {
  const VentilacionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(ventilacionProvider);
    final vm = ref.read(ventilacionProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ventilación",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'logout') {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      itemBuilder:
                          (context) => const [
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Text("Cerrar sesión"),
                            ),
                          ],
                      child: const Text(
                        "mas",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          estado.ventiladorActivo
                              ? Icons.toys
                              : Icons.toys_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          estado.ventiladorActivo
                              ? "Ventilador Encendido"
                              : "Ventilador Apagado",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: vm.toggleVentilador,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      estado.ventiladorActivo
                          ? "Apagar Ventilador"
                          : "Encender Ventilador",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: vm.activarModoAutomatico,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CA6FF),
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Modo Automático"),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_remote, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Estado del sistema",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            estado.modoAutomatico
                                ? "Modo automático activado"
                                : estado.ventiladorActivo
                                ? "Ventilador activado manualmente"
                                : "Ventilador apagado",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Historial de ventilación",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirebaseService.fetchHistorialVentilacion(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                        "No hay historial disponible.",
                        style: TextStyle(color: Colors.white70),
                      );
                    }
                    final historial = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final item = historial[index];
                        final fecha = DateFormat('dd/MM/yyyy – HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            item['timestamp'],
                          ),
                        );
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['accion'] == 'encender'
                                    ? Icons.air
                                    : Icons.air_outlined,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Acción: ${item['accion'].toString().toUpperCase()}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Dispositivo: ${item['dispositivoId']}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      "Fecha: $fecha",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
