import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(authProvider.notifier).login(
            emailController.text.trim(),
            passwordController.text,
          );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Correo o contraseña incorrectos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Iniciar Sesión', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'El correo no puede estar vacío';
                  if (!value.contains('@')) return 'Debes ingresar un correo válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'La contraseña no puede estar vacía';
                  if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
