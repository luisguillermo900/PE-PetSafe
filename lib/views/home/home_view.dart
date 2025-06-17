import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../viewmodels/temperatura_viewmodel.dart';
import '../../viewmodels/ventilacion_viewmodel.dart';
import '../../viewmodels/iluminacion_viewmodel.dart';
import '../../viewmodels/calendario_viewmodel.dart';
import '../temperatura/temperatura_view.dart';
import '../ventilacion/ventilacion_view.dart';
import '../iluminacion/iluminacion_view.dart';
import '../calendario/calendario_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeProvider);
    final homeVM = ref.read(homeProvider.notifier);
    final temperatura = ref.watch(temperaturaProvider);
    final ventilacion = ref.watch(ventilacionProvider);
    final ventilacionVM = ref.read(ventilacionProvider.notifier);
    final iluminacion = ref.watch(iluminacionProvider);
    final iluminacionVM = ref.read(iluminacionProvider.notifier);
    final calendario = ref.watch(calendarioProvider);
    final user = ref.watch(userProvider);

    final ultimoEvento =
        calendario.eventos.isNotEmpty ? calendario.eventos.first : null;

    // Automatizaciones
    if (temperatura.temperatura > 30 &&
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
    }

    final List<Widget> vistas = [
      _buildHomeContent(
        context,
        ref,
        temperatura,
        ventilacion,
        iluminacion,
        user,
        ultimoEvento,
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
    WidgetRef ref,
    TemperaturaState temperatura,
    VentilacionState ventilacion,
    IluminacionState iluminacion,
    UserModel user,
    dynamic ultimoEvento,
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
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Text("Cerrar sesión"),
                        ),
                      ],
                ),
              ],
            ),
          ),

          _animatedAlert(
            child: Column(
              key: const ValueKey("alertas_multiples"),
              children: [
                if (temperatura.temperatura > 30)
                  _fadeInCard(
                    key: const ValueKey("alerta_calor"),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "¡Alerta! La temperatura supera los 30°C. Se recomienda activar ventilación.",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (temperatura.temperatura < 15)
                  _fadeInCard(
                    key: const ValueKey("alerta_frio"),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.ac_unit, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "¡Alerta! La temperatura es muy baja.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Se recomienda encender iluminación o calefacción.",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    final iluminacionVM = ref.read(
                                      iluminacionProvider.notifier,
                                    );
                                    iluminacionVM.toggleLuz();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Luz activada manualmente desde la alerta.",
                                        ),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Encender Luz"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (temperatura.temperatura >= 15 &&
                    temperatura.temperatura < 18)
                  _fadeInCard(
                    key: const ValueKey("advertencia_frio"),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber, color: Colors.black),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Advertencia: La temperatura es baja. Considere activar la iluminación.",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              _widgetCard(
                context,
                label:
                    "${temperatura.temperatura} °C\n${temperatura.humedad}% humedad",
                icon: Icons.thermostat,
                onTap: () => ref.read(homeProvider.notifier).state = 1,
              ),
              _widgetCard(
                context,
                label:
                    iluminacion.luzActiva ? "Luz\nEncendida" : "Luz\nApagada",
                icon: Icons.lightbulb_outline,
                onTap: () => ref.read(homeProvider.notifier).state = 2,
              ),
              _widgetCard(
                context,
                label:
                    ventilacion.ventiladorActivo
                        ? "Ventilador\nActivo"
                        : "Ventilador\nApagado",
                icon: Icons.air,
                onTap: () => ref.read(homeProvider.notifier).state = 3,
              ),
            ],
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

          if (ultimoEvento != null)
            _historialItem(
              icon: Icons.calendar_today,
              titulo: ultimoEvento.titulo,
              subtitulo: "${ultimoEvento.descripcion} - ${ultimoEvento.fecha}",
            )
          else
            _historialItem(
              icon: Icons.info_outline,
              titulo: "Sin eventos",
              subtitulo: "No hay actividades programadas",
            ),
        ],
      ),
    );
  }

  Widget _fadeInCard({required Widget child, Key? key}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }

  Widget _animatedAlert({required Widget? child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: child,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
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
