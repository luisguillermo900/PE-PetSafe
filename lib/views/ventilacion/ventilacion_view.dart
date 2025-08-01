import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';
import '../../providers/providers.dart';
import '../../services/firebase_service.dart';

class VentilacionView extends ConsumerStatefulWidget {
  const VentilacionView({super.key});

  @override
  ConsumerState<VentilacionView> createState() => _VentilacionViewState();
}

class _VentilacionViewState extends ConsumerState<VentilacionView> {
  @override
  void initState() {
    super.initState();

    // Cargar datos al abrir la vista
    Future.microtask(() {
      ref.read(alertasProvider.notifier).cargarAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(
                                sensoresProvider.select((s) => s.temperatura),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.5),
                              child: Text(
                                '°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      vm.toggleVentilador();
                      final bloc = ref.watch(awsIotBlocProvider);
                      final nuevoEstado = ref.read(ventilacionProvider);
                      final mensaje = jsonEncode({
                        'ventilacionManual': true,
                        'ventilacionEncendida': nuevoEstado.ventiladorActivo,
                      });
                      if (bloc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No conectado a AWS IoT'),
                          ),
                        );
                        return;
                      }
                      bloc.add(AwsIotSendMessage(mensaje));
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
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
                    onPressed: () {
                      vm.activarModoAutomatico();
                      final bloc = ref.watch(awsIotBlocProvider);
                      final mensaje = jsonEncode({
                        'ventilacionManual': false,
                        'ventilacionEncendida': estado.ventiladorActivo,
                      });
                      if (bloc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No conectado a AWS IoT'),
                          ),
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
                    child: const Text(
                      "Modo Automático",
                      style: TextStyle(color: Colors.white),
                    ),
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
                Consumer(
                  builder: (context, ref, _) {
                    final alertas = ref.watch(alertasProvider);
                    final historial =
                        alertas
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
                                color:
                                    item.estado == 'encendido'
                                        ? Colors.red
                                        : Colors.blue,
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
                                          ? "Ventilación ENCENDIDA automáticamente"
                                          : "Ventilación APAGADA automáticamente",
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
