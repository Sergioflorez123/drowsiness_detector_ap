import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';
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
  bool _showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.errorLogin),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final loading = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF030A1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05142F), Color(0xFF020817)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF1EE7FF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'EYE ALERT',
                            style: TextStyle(
                              color: Color(0xFF1EE7FF),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: const Icon(
                              Icons.settings_rounded,
                              color: Color(0xFF7AB1C0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l.loginTitle,
                        style: const TextStyle(
                          color: Color(0xFFD7F8FF),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.appTagline,
                        style: const TextStyle(
                          color: Color(0xFF587998),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Color(0xFFD7F8FF)),
                        decoration: InputDecoration(
                          labelText: l.emailLabel,
                          labelStyle: const TextStyle(color: Color(0xFF72BCD0)),
                          prefixIcon: const Icon(
                            Icons.alternate_email_rounded,
                            color: Color(0xFF5AC7DC),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A1733),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color(0xFF2B4B68).withValues(alpha: 0.55),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF1EE7FF),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l.validatorEmailEmpty;
                          }
                          if (!value.contains('@')) {
                            return l.validatorEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_showPassword,
                        style: const TextStyle(color: Color(0xFFD7F8FF)),
                        decoration: InputDecoration(
                          labelText: l.passwordLabel,
                          labelStyle: const TextStyle(color: Color(0xFF72BCD0)),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF5AC7DC),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF4F708E),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A1733),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color(0xFF2B4B68).withValues(alpha: 0.55),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF1EE7FF),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l.validatorPasswordEmpty;
                          }
                          if (value.length < 6) {
                            return l.validatorPasswordShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1EE7FF),
                          foregroundColor: const Color(0xFF002030),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: loading ? null : _submit,
                        icon: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF002030),
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(
                          loading ? l.splashLoading : l.enterButton,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          l.noAccount,
                          style: const TextStyle(color: Color(0xFF66BFD1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
