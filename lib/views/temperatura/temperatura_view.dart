import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';

class TemperaturaView extends ConsumerWidget {
  const TemperaturaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temperaturaState = ref.watch(temperaturaProvider);
    final viewModel = ref.read(temperaturaProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        title: const Text('Temperatura'),
        backgroundColor: const Color(0xFF0F5C94),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_cloudy, size: 100, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              '${temperaturaState.temperatura} °C',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: viewModel.toggleCalefaccion,
              child: Text(
                temperaturaState.calefaccionActiva
                    ? 'Desactivar Calefacción'
                    : 'Activar Calefacción',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: viewModel.activarModoAutomatico,
              child: const Text('Calefacción Automática'),
            ),
            const SizedBox(height: 20),
            Text(
              temperaturaState.modoAutomatico
                  ? '🔄 Calefacción automática activada'
                  : (temperaturaState.calefaccionActiva
                      ? '🔥 Calefacción activada'
                      : '❄️ Calefacción desactivada'),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
