import 'package:flutter/material.dart';
import '../views/login/login_view.dart';
import '../views/home/home_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetSafe',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginView(),
        '/home': (_) => const HomeView(),
      },
    );
  }
}
