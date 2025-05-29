import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../temperatura/temperatura_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeProvider);
    final vm = ref.read(homeProvider.notifier);

    final List<Widget> vistas = [
      const Center(child: Text("Inicio")),         // índice 0
      const TemperaturaView(),   // índice 1
      const Center(child: Text("Mapa")),// índice 2
      const Center(child: Text("Historial")),     // índice 3 
                 
                       
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF134B70),
        title: const Text("PetSafe"),
      ),
      body: vistas[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: vm.changeTab,
        backgroundColor: const Color(0xFF508C9B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: "Temperatura"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historial"),
        ],
      ),
    );
  }
}
