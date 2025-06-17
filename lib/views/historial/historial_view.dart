/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class HistorialView extends ConsumerWidget {
  const HistorialView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historialProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.historial.isEmpty) {
      return const Center(child: Text('No hay historial.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.historial.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = state.historial[index];
        return ListTile(
          leading: Icon(
            item.evento == 'Paseo'
                ? Icons.directions_walk
                : item.evento == 'Veterinario'
                    ? Icons.local_hospital
                    : item.evento == 'Alimentación'
                        ? Icons.restaurant
                        : Icons.pets,
            color: Colors.blueAccent,
          ),
          title: Text(item.evento),
          subtitle: Text(item.detalle),
          trailing: Text(item.fecha),
        );
      },
    );
  }
}*/
