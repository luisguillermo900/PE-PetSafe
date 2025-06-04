import 'package:flutter/material.dart';

class CalendarioView extends StatelessWidget {
  const CalendarioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Calendario",
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
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text("Cerrar sesión"),
                      ),
                    ],
                    child: const Text("mas", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

         
              Expanded(
                child: ListView(
                  children: const [
                    _EventoCalendario(
                      icon: Icons.directions_walk,
                      titulo: "Paseo",
                      subtitulo: "30 minutos en el parque",
                      fecha: "28/05/2025",
                    ),
                    _EventoCalendario(
                      icon: Icons.local_hospital,
                      titulo: "Veterinario",
                      subtitulo: "Vacuna anual aplicada",
                      fecha: "27/05/2025",
                    ),
                    _EventoCalendario(
                      icon: Icons.restaurant,
                      titulo: "Alimentación",
                      subtitulo: "Comida especial para dieta",
                      fecha: "26/05/2025",
                    ),
                    _EventoCalendario(
                      icon: Icons.pets,
                      titulo: "Baño",
                      subtitulo: "Baño y corte de uñas",
                      fecha: "25/05/2025",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventoCalendario extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final String fecha;

  const _EventoCalendario({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(fecha, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
