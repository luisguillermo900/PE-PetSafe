import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lab04/views/temperatura/temperature_view.dart';
import '../../providers/providers.dart';
import '../../services/blocs/aws_iot_bloc.dart';
import '../../services/firebase_service.dart';

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Temperatura",
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
                        const Icon(
                          Icons.wb_cloudy,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${ref.watch(sensoresProvider.select((s) => s.temperatura))} °C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        //TemperatureView(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: ElevatedButton(
                    onPressed: (){
                      viewModel.toggleCalefaccion();
                      final bloc = ref.watch(awsIotBlocProvider);
                      final mensaje = jsonEncode({
                        'ventilacionManual': true,
                        'ventilacionEncendida': temperaturaState.calefaccionActiva
                      });
                      if (bloc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No conectado a AWS IoT')),
                        );
                        return;
                      }
                      bloc.add(AwsIotSendMessage(mensaje));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      temperaturaState.calefaccionActiva
                          ? "Desactivar Calefacción"
                          : "Activar Calefacción",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: (){
                      viewModel.activarModoAutomatico();
                      final bloc = ref.watch(awsIotBlocProvider);
                      final mensaje = jsonEncode({
                        'ventilacionManual': false,
                        'ventilacionEncendida': temperaturaState.calefaccionActiva
                      });
                      if (bloc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No conectado a AWS IoT')),
                        );
                        return;
                      }
                      bloc.add(AwsIotSendMessage(mensaje));
                    },
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

                const SizedBox(height: 24),
                const Text(
                  "Historial de alertas",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, _) {
                    final alertas = ref.watch(alertasProvider);
                    final historial = alertas
                      .where((a) => a.nombre == "ventilacion")
                      .toList()
                      .reversed
                      .toList();
                    if (historial.isEmpty) {
                      return const Text(
                        "No hay historial disponible.",
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final item = historial[index];
                        final fecha = item.tiempo;

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
                                Icons.thermostat,
                                color: item.estado == 'encendido' ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.estado == 'encendido'
                                      ? "Temperatura alta detectada"
                                      : "Temperatura baja detectada",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item.estado == 'encendido'
                                      ? "Calefacción APAGADA automáticamente"
                                      : "Calefacción ENCENDIDA automáticamente",
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
