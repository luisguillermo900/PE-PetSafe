import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab04/models/lectura_model.dart';
import '../models/user_model.dart';
import 'package:lab04/services/blocs/aws_iot_bloc.dart';
import '../viewmodels/lecturas_notifier.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/temperatura_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/historial_viewmodel.dart';
import '../viewmodels/calendario_viewmodel.dart';
import '../viewmodels/ventilacion_viewmodel.dart';
import '../viewmodels/iluminacion_viewmodel.dart';
import '../viewmodels/sensores_notifier.dart';
import '../viewmodels/dispositivos_notifier.dart';
import '../viewmodels/alertas_notifier.dart';
import '../services/dynamoDB_service.dart';
import '../models/dispositivos_state.dart';

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

final userProvider = StateNotifierProvider<UserViewModel, UserModel>(
  (ref) => UserViewModel(),
);

final historialProvider =
    StateNotifierProvider<HistorialViewModel, HistorialState>(
      (ref) => HistorialViewModel(),
    );

final calendarioProvider =
    StateNotifierProvider<CalendarioViewModel, CalendarioState>(
      (ref) => CalendarioViewModel(),
    );

final ventilacionProvider =
    StateNotifierProvider<VentilacionViewModel, VentilacionState>(
      (ref) => VentilacionViewModel(),
    );

final iluminacionProvider =
    StateNotifierProvider<IluminacionViewModel, IluminacionState>(
      (ref) => IluminacionViewModel(),
    );

final awsIotBlocProvider = StateProvider<AwsIotBloc?>((ref) => null);

final sensoresProvider = StateNotifierProvider<SensoresNotifier, SensoresState>(
  (ref) => SensoresNotifier(),
);

final dispositivosProvider = StateNotifierProvider<DispositivosNotifier, DispositivosState>((ref) {
  final alertasNotifier = ref.read(alertasProvider.notifier);
  return DispositivosNotifier(alertasNotifier);
});

final dynamodbServiceProvider = Provider<DynamodbService>((ref) {
  return DynamodbService();
});

final alertasProvider = StateNotifierProvider<AlertasNotifier, List<DispositivosState>>((ref) {
  final servicio = ref.read(dynamodbServiceProvider);
  return AlertasNotifier(servicio);
});

final lecturasStateProvider = StateNotifierProvider<LecturasNotifier, List<Lectura>>((ref) {
  final servicios = ref.read(dynamodbServiceProvider);
  return LecturasNotifier(servicios);
}); 

