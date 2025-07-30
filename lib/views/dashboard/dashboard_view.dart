import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(lecturasStateProvider.notifier).cargarLecturas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lecturas = ref.watch(lecturasStateProvider);

    if (lecturas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    Map<int, double> temperaturasPorHora = {};

    for (var lectura in lecturas) {
      try {
        final fecha = DateFormat('dd/MM/yy HH:mm:ss').parse(lectura.tiempo);
        final hora = fecha.hour;
        final temp = lectura.temperatura;

        bool esDia = hora >= 6 && hora < 18;

        if (!temperaturasPorHora.containsKey(hora)) {
          temperaturasPorHora[hora] = temp;
        } else {
          double valorExistente = temperaturasPorHora[hora]!;
          temperaturasPorHora[hora] =
              esDia
                  ? (temp > valorExistente
                      ? temp
                      : valorExistente) 
                  : (temp < valorExistente
                      ? temp
                      : valorExistente);
        }
      } catch (e) {
        print('Error de fecha: ${lectura.tiempo}');
      }
    }

    List<FlSpot> spots =
        temperaturasPorHora.entries
            .map((lectura) => FlSpot(lectura.key.toDouble(), lectura.value))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dashboard",
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
    
                SizedBox(height: 30),
    
                Container(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      minY: 5,
                      maxY: 40,
                      lineBarsData: [
                        LineChartBarData(
                          show: true,
                          spots: spots,
                          isCurved: false,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          isStrokeCapRound: true,
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 241, 244, 54),
                              Color.fromARGB(255, 183, 255, 88),
                              Color.fromARGB(255, 68, 186, 255),
                            ],
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.pink.withAlpha(100),
                          ),
                          aboveBarData: BarAreaData(
                            show: true,
                            color: Colors.amber.withAlpha(100),
                          ),
                          shadow: Shadow(color: Colors.black87, blurRadius: 20),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 3,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final hour = value.toInt();
                              final amPm = hour >= 12 ? 'pm' : 'am';
                              final displayHour =
                                  hour % 12 == 0 ? 12 : hour % 12;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '$displayHour$amPm',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 40,
                            getTitlesWidget:
                                (value, meta) => Text(
                                  '${value.toInt()}°C',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                        topTitles: AxisTitles(
                          axisNameWidget: Text(
                            'horas/dia',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          axisNameSize: 30,
                          sideTitles: SideTitles(
                            showTitles: false,
                          ), // Ocultar parte superior
                        ),
                        rightTitles: AxisTitles(
                          axisNameWidget: Text(
                            'temperatura',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          axisNameSize: 20,
                          sideTitles: SideTitles(
                            showTitles: false,
                          ), // Ocultar derecha
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.blue, width: 4),
                          bottom: BorderSide(color: Colors.blue, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
