import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});
}

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel() : super(LoginState());

  Future<void> login(String username, String password) async {
    state = LoginState(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    if (username == "admin" && password == "1234") {
      state = LoginState(); // login correcto
    } else {
      state = LoginState(error: "Credenciales inválidas");
    }
  }
}
