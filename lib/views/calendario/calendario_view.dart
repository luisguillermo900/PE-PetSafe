import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/evento_model.dart';
import '../../providers/providers.dart';
import '../../viewmodels/calendario_viewmodel.dart';

class CalendarioView extends ConsumerWidget {
  const CalendarioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(calendarioProvider.notifier);
    final state = ref.watch(calendarioProvider);

    final eventosDelDia = viewModel.obtenerEventosDelDia(state.selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFF0F5C94),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
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
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Text("Cerrar sesión"),
                          ),
                        ],
                    child: const Text(
                      "mas",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendario
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: state.selectedDay,
                selectedDayPredicate:
                    (day) => isSameDay(day, state.selectedDay),
                onDaySelected: (selectedDay, _) {
                  viewModel.seleccionarDia(selectedDay);
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.white),
                  defaultTextStyle: TextStyle(color: Colors.white),
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white),
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),

              // Lista de eventos
              Text(
                "Eventos del ${DateFormat('d/M/y').format(state.selectedDay)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (eventosDelDia.isEmpty)
                const Text(
                  "No hay eventos",
                  style: TextStyle(color: Colors.white70),
                ),
              if (eventosDelDia.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: eventosDelDia.length,
                    itemBuilder: (context, index) {
                      final evento = eventosDelDia[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => _buildEditarDialog(
                                  context,
                                  viewModel,
                                  evento,
                                ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evento.titulo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      evento.descripcion,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                evento.fecha,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) =>
                    _buildAgregarDialog(context, viewModel, state.selectedDay),
          );
        },
      ),
    );
  }

  // Diálogo para agregar evento
  Widget _buildAgregarDialog(
    BuildContext context,
    CalendarioViewModel viewModel,
    DateTime fechaSeleccionada,
  ) {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    return AlertDialog(
      title: const Text("Nuevo evento"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tituloController,
            decoration: const InputDecoration(labelText: "Título"),
          ),
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: "Descripción"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final fecha = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
            viewModel.agregarEvento(
              titulo: tituloController.text,
              descripcion: descripcionController.text,
              fecha: fecha,
            );
            Navigator.pop(context);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }

  // Diálogo para editar evento
  Widget _buildEditarDialog(
    BuildContext context,
    CalendarioViewModel viewModel,
    EventoModel evento,
  ) {
    final descripcionController = TextEditingController(
      text: evento.descripcion,
    );
    final fechaActual = DateTime.parse(evento.fecha);
    DateTime nuevaFecha = fechaActual;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Editar ${evento.titulo}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              const SizedBox(height: 8),
              Text("Fecha: ${DateFormat('yyyy-MM-dd').format(nuevaFecha)}"),
              TextButton(
                onPressed: () async {
                  final nueva = await showDatePicker(
                    context: context,
                    initialDate: nuevaFecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (nueva != null) setState(() => nuevaFecha = nueva);
                },
                child: const Text("Cambiar fecha"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.editarEvento(
                  id: evento.id!,
                  descripcion: descripcionController.text,
                  fecha: DateFormat('yyyy-MM-dd').format(nuevaFecha),
                );
                Navigator.pop(context);
              },
              child: const Text("Actualizar"),
            ),
          ],
        );
      },
    );
  }
}
