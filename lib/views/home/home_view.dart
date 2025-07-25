import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab04/views/temperatura/temperatura_view.dart';
import 'package:lab04/views/temperatura/temperature_view.dart';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../viewmodels/temperatura_viewmodel.dart';
import '../../viewmodels/ventilacion_viewmodel.dart';
import '../../viewmodels/iluminacion_viewmodel.dart';
import '../../viewmodels/sensores_notifier.dart';
import '../../services/firebase_service.dart';
import '../ventilacion/ventilacion_view.dart';
import '../iluminacion/iluminacion_view.dart';
import '../calendario/calendario_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  List<Map<String, dynamic>> alertas = [];

  @override
  void initState() {
    super.initState();
    cargarAlertasDesdeFirebase();
  }

  Future<void> cargarAlertasDesdeFirebase() async {
    final data = await FirebaseService.fetchAlertas();
    setState(() {
      alertas = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeProvider);
    final homeVM = ref.read(homeProvider.notifier);
    final temperatura = ref.watch(temperaturaProvider);
    final ventilacion = ref.watch(ventilacionProvider);
    final ventilacionVM = ref.read(ventilacionProvider.notifier);
    final iluminacion = ref.watch(iluminacionProvider);
    final iluminacionVM = ref.read(iluminacionProvider.notifier);
    final calendario = ref.watch(calendarioProvider);
    final calendarioVM = ref.read(calendarioProvider.notifier);
    final user = ref.watch(userProvider);
    //final estadoSensores = ref.watch(sensoresProvider);
    final hoy = DateTime.now();
    final eventosHoy = calendarioVM.obtenerEventosDelDia(hoy);

    // Automatizaciones
    /*if (temperatura.temperatura > 30 &&
        ventilacion.modoAutomatico &&
        !ventilacion.ventiladorActivo) {
      Future.microtask(() {
        ventilacionVM.activarVentilador();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Ventilación activada automáticamente por temperatura alta.",
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }

    if (temperatura.temperatura < 18 &&
        iluminacion.modoAutomatico &&
        !iluminacion.luzActiva) {
      Future.microtask(() {
        iluminacionVM.activarLuz();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Luz activada automáticamente por temperatura baja.",
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }*/

    final List<Widget> vistas = [
      _buildHomeContent(
        context,
        temperatura,
        ventilacion,
        iluminacion,
        user,
        eventosHoy,
        //estadoSensores,
      ),
      const TemperaturaView(),
      const IluminacionView(),
      const VentilacionView(),
      const CalendarioView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: vistas[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: homeVM.changeTab,
        backgroundColor: const Color(0xFF001E5A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat),
            label: "Temperatura",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: "Luz",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.air), label: "Ventilación"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendario",
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    TemperaturaState temperatura,
    VentilacionState ventilacion,
    IluminacionState iluminacion,
    UserModel user,
    List eventosHoy,
    //SensoresState estadoSensores,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout' && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  color: Colors.white,
                  child: const Text(
                    "mas",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text("Cerrar sesión"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Usuario
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/perfil.jpeg'),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Text(
                      "Bienvenido, Luis G.!",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Indicadores",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
      child: _widgetCard(
        context,
        label: "${ref.watch(sensoresProvider.select((s) => s.temperatura))} °C\n${ref.watch(sensoresProvider.select((s) => s.humedad))}% humedad",
        icon: Icons.thermostat,
        onTap: () => ref.read(homeProvider.notifier).state = 1,
      ),
    ),
    SizedBox(width: 8), // opcional, para un poco de espacio horizontal entre cards
    Expanded(
      child: _widgetCard(
        context,
        label: iluminacion.luzActiva ? "Luz\nEncendida" : "Luz\nApagada",
        icon: Icons.lightbulb_outline,
        onTap: () => ref.read(homeProvider.notifier).state = 2,
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: _widgetCard(
        context,
        label: ventilacion.ventiladorActivo
            ? "Ventilador\nActivo"
            : "Ventilador\nApagado",
        icon: Icons.air,
        onTap: () => ref.read(homeProvider.notifier).state = 3,
      ),
    ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            "Alertas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...alertas.map(
            (alerta) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta['mensaje'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tipo: ${alerta['tipo']} | Valor: ${alerta['valorMedido']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Agenda",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (eventosHoy.isNotEmpty)
            ...eventosHoy.map((evento) => _historialItem(
                  icon: Icons.calendar_today,
                  titulo: evento.titulo,
                  subtitulo: "${evento.descripcion} - ${evento.fecha}",
                ))
          else
            _historialItem(
              icon: Icons.info_outline,
              titulo: "Sin eventos",
              subtitulo: "No hay actividades programadas hoy",
            ),
        ],
      ),
    );
  }

  Widget _widgetCard(
    BuildContext context, {
    required String label,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historialItem({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
