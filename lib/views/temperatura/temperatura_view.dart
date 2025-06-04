import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class TemperaturaView extends ConsumerWidget {
  const TemperaturaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temperaturaState = ref.watch(temperaturaProvider);
    final viewModel = ref.read(temperaturaProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Temperatura",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'logout') {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    itemBuilder: (context) => const [
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
                      const Icon(Icons.wb_cloudy, size: 60, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        "${temperaturaState.temperatura} °C",
                        style: const TextStyle(color: Colors.white, fontSize: 28),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.toggleCalefaccion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    temperaturaState.calefaccionActiva ? "Desactivar Calefacción" : "Activar Calefacción",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón 
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.activarModoAutomatico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA6FF),
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Calefacción Automática"),
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
                    const Icon(Icons.directions_walk, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Temperatura", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          temperaturaState.modoAutomatico
                              ? "Calefacción automática activada"
                              : temperaturaState.calefaccionActiva
                                  ? "Calefacción activada"
                                  : "Calefacción desactivada",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
