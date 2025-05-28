import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeProvider);
    final vm = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF134B70),
        title: const Text("PetSafe"),
      ),
      body: Center(
        child: Text("Vista actual: $index"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: vm.changeTab,
        backgroundColor: const Color(0xFF508C9B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
        ],
      ),
    );
  }
}
