import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/temperatura_viewmodel.dart';

final loginProvider = StateNotifierProvider<LoginViewModel, LoginState>(
  (ref) => LoginViewModel(),
);

final homeProvider = StateNotifierProvider<HomeViewModel, int>(
  (ref) => HomeViewModel(),
);

final temperaturaProvider =
    StateNotifierProvider<TemperaturaViewModel, TemperaturaState>(
  (ref) => TemperaturaViewModel(),
);