import 'dart:convert';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../services/firebase_service.dart';

class IluminacionView extends ConsumerStatefulWidget {
  const IluminacionView({super.key});

  @override
  ConsumerState<IluminacionView> createState() => _IluminacionViewState();
}

class _IluminacionViewState extends ConsumerState<IluminacionView> {
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
    final estado = ref.watch(iluminacionProvider);
    final vm = ref.read(iluminacionProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Iluminación",
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

                // Icono luz
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
                          estado.luzActiva
                              ? Icons.lightbulb
                              : Icons.lightbulb_outline,
                          size: 60,
                          color:
                              estado.luzActiva
                                  ? Colors.yellow[600]
                                  : Colors.white, //Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${ref.watch(sensoresProvider.select((s) => s.iluminancia))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.5),
                              child: Text(
                                ' lx',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w200,
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

                // Botón encender/apagar
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      vm.toggleLuz();

                      // Luego, envía el mensaje JSON a través del bloc
                      final bloc = ref.watch(awsIotBlocProvider);
                      final nuevoEstado = ref.read(iluminacionProvider);
                      final mensaje = jsonEncode({
                        'iluminacionManual': true,
                        'iluminacionEncendida': nuevoEstado.luzActiva,
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
                      estado.luzActiva ? "Apagar Luz" : "Encender Luz",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón automático
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      vm.activarModoAutomatico();
                      // Luego, envía el mensaje JSON a través del bloc
                      final bloc = ref.watch(awsIotBlocProvider);
                      final mensaje = jsonEncode({
                        'iluminacionManual': false,
                        'iluminacionEncendida': estado.luzActiva,
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
                    child: const Text("Modo Automático"),
                  ),
                ),

                const SizedBox(height: 30),

                // Estado
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
                                : estado.luzActiva
                                ? "Luz encendida"
                                : "Luz apagada",
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
                    final historial =
                        alertas
                            .where((a) => a.nombre == "iluminacion")
                            .toList()
                            .reversed
                            .toList();
                    print("Historial: $historial");
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
                                item.estado == 'encendido'
                                    ? Icons.lightbulb
                                    : Icons.lightbulb_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.estado == 'encendido'
                                          ? "Iluminación baja detectada"
                                          : "Iluminación alta detectada",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item.estado == 'encendido'
                                          ? "Luz ENCENDIDA automáticamente"
                                          : "Luz APAGADA automáticamente",
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
