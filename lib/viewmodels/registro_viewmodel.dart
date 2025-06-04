import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/registro_model.dart';

class RegistroState {
  final String? mensajeExito;
  final String? error;

  RegistroState({this.mensajeExito, this.error});
}

class RegistroViewModel extends StateNotifier<RegistroState> {
  RegistroViewModel() : super(RegistroState());

  Future<void> registrar(RegistroModel usuario, String repetirContrasena) async {
    if (usuario.nombres.isEmpty ||
        usuario.apellidos.isEmpty ||
        usuario.correo.isEmpty ||
        usuario.usuario.isEmpty ||
        usuario.contrasena.isEmpty ||
        repetirContrasena.isEmpty) {
      state = RegistroState(error: "Todos los campos son obligatorios.");
      return;
    }

    if (!usuario.correo.contains('@')) {
      state = RegistroState(error: "Correo electrónico inválido.");
      return;
    }

    if (usuario.contrasena != repetirContrasena) {
      state = RegistroState(error: "Las contraseñas no coinciden.");
      return;
    }

    // Simulación de éxito
    await Future.delayed(const Duration(seconds: 1));
    state = RegistroState(mensajeExito: "Cuenta creada con éxito.");
  }
}
