import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import '../../viewmodels/temperatura_viewmodel.dart';
import '../temperatura/temperatura_view.dart';
import '../ubicacion/ubicacion_view.dart';
import '../calendario/calendario_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeProvider);
    final homeVM = ref.read(homeProvider.notifier);
    final temperatura = ref.watch(temperaturaProvider);
    final user = ref.watch(userProvider);

    final List<Widget> vistas = [
      _buildHomeContent(context, ref, temperatura, user),
      const UbicacionView(),
      const TemperaturaView(),
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
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Ubicación"),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Temperatura"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendario"),
        ],
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    TemperaturaState temperatura,
    UserModel user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado Home
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Home",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout' && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  color: Colors.white,
                  child: const Text("mas", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    Text(user.username, style: const TextStyle(color: Colors.white, fontSize: 18)),
                    const Text("Bienvenido, Luis G.!", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("Widgets", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Widgets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _widgetCard(
                context,
                label: "Ubicación",
                icon: null,
                imagePath: 'assets/mapa_demo.png',
                onTap: () => ref.read(homeProvider.notifier).state = 1,
              ),
              _widgetCard(
                context,
                label: "${temperatura.temperatura} °C",
                icon: Icons.wb_cloudy,
                onTap: () => ref.read(homeProvider.notifier).state = 2,
              ),
              _widgetCard(
                context,
                label: temperatura.calefaccionActiva || temperatura.modoAutomatico ? "Activado" : "Apagado",
                icon: Icons.lightbulb,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text("Resumen", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _historialItem(icon: Icons.thermostat, titulo: "Temperatura", subtitulo: "30°C"),
          _historialItem(icon: Icons.location_on, titulo: "Ubicación", subtitulo: "30 minutos en el parque"),
        ],
      ),
    );
  }

  Widget _widgetCard(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? imagePath,
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
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(imagePath, height: 40, fit: BoxFit.cover),
              ),
            if (icon != null)
              Icon(icon, color: Colors.white, size: 30),
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

  Widget _historialItem({required IconData icon, required String titulo, required String subtitulo}) {
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
                Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
