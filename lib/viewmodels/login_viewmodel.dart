import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});
}

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel() : super(LoginState());

  Future<void> login(String username, String password, WidgetRef ref) async {
    state = LoginState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    if (username == "admin" && password == "1234") {
      state = LoginState(); // login correcto
      final dispositivosNotifier = ref.read(dispositivosProvider.notifier);
      final sensoresNotifier = ref.read(sensoresProvider.notifier);
      final alertasNotifier = ref.read(alertasProvider.notifier);
      await alertasNotifier.cargarAlertas();
      debugPrint("Cargando registro de alertas");
      final bloc = AwsIotBloc(sensoresNotifier: sensoresNotifier, dispositivosNotifier: dispositivosNotifier);
      bloc.add(AwsIotConnect());
      
      // Guardarlo en el provider
      ref.read(awsIotBlocProvider.notifier).state = bloc;
    } else {
      state = LoginState(error: "Credenciales inválidas");
    }
  }
}
