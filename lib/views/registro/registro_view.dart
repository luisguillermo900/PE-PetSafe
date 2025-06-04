import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/registro_model.dart';
import '../../viewmodels/registro_viewmodel.dart';

final registroProvider = StateNotifierProvider<RegistroViewModel, RegistroState>(
  (ref) => RegistroViewModel(),
);

class RegistroView extends ConsumerWidget {
  const RegistroView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registroProvider);
    final vm = ref.read(registroProvider.notifier);

    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final celularCtrl = TextEditingController();
    final usuarioCtrl = TextEditingController();
    final contraCtrl = TextEditingController();
    final repetirCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF102C6B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text("Nuevo usuario", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 20),
                _campo(nombreCtrl, "Nombres"),
                _campo(apellidoCtrl, "Apellidos"),
                _campo(correoCtrl, "Correo"),
                _campo(celularCtrl, "Celular"),
                _campo(usuarioCtrl, "Usuario"),
                _campo(contraCtrl, "Contraseña", isPassword: true),
                _campo(repetirCtrl, "Repetir Contraseña", isPassword: true),
                const SizedBox(height: 10),
                if (state.error != null)
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                if (state.mensajeExito != null)
                  Text(state.mensajeExito!, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoUsuario = RegistroModel(
                      nombres: nombreCtrl.text,
                      apellidos: apellidoCtrl.text,
                      correo: correoCtrl.text,
                      celular: celularCtrl.text,
                      usuario: usuarioCtrl.text,
                      contrasena: contraCtrl.text,
                    );

                    await vm.registrar(nuevoUsuario, repetirCtrl.text);

                    if (ref.read(registroProvider).mensajeExito != null && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102C6B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Crear cuenta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
