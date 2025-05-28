import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../home/home_view.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginVM = ref.read(loginProvider.notifier);

    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("PetSafe", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 30),
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(hintText: "Usuario", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Contraseña", border: OutlineInputBorder()),
              ),
              if (loginState.error != null) ...[
                const SizedBox(height: 8),
                Text(loginState.error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginState.isLoading
                    ? null
                    : () async {
                        await loginVM.login(userCtrl.text, passCtrl.text);
                        if (ref.read(loginProvider).error == null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeView()),
                          );
                        }
                      },
                child: loginState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Iniciar Sesión"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
