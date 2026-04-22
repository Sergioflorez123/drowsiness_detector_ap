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
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A1A39), Color(0xFF091530)],
                          ),
                          border: Border.all(
                            color: const Color(0xFF1EE7FF).withOpacity(0.26),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1EE7FF).withOpacity(0.15),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Container(
                          height: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF061126),
                            border: Border.all(
                              color: const Color(0xFF2CDFFF).withOpacity(0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            size: 62,
                            color: Color(0xFF23DEFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1EE7FF),
                          foregroundColor: const Color(0xFF002030),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'SCAN TO LOGIN',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFF2D4863).withOpacity(0.7),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR PROVIDE CREDENTIALS',
                              style: TextStyle(
                                color: Color(0xFF587998),
                                fontSize: 10,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFF2D4863).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Color(0xFFD7F8FF)),
                        decoration: InputDecoration(
                          labelText: 'Neural ID',
                          labelStyle: const TextStyle(color: Color(0xFF72BCD0)),
                          prefixIcon: const Icon(
                            Icons.alternate_email_rounded,
                            color: Color(0xFF5AC7DC),
                          ),
                          hintText: 'username@neural.net',
                          hintStyle: const TextStyle(color: Color(0xFF4F708E)),
                          filled: true,
                          fillColor: const Color(0xFF0A1733),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color(0xFF2B4B68).withOpacity(0.55),
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
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFFD7F8FF)),
                        decoration: InputDecoration(
                          labelText: 'Passkey',
                          labelStyle: const TextStyle(color: Color(0xFF72BCD0)),
                          prefixIcon: const Icon(
                            Icons.key_outlined,
                            color: Color(0xFF5AC7DC),
                          ),
                          suffixIcon: const Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF4F708E),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A1733),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: const Color(0xFF2B4B68).withOpacity(0.55),
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
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1EE7FF),
                          side: const BorderSide(color: Color(0xFF1EE7FF)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: loading ? null : _submit,
                        icon: loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login_rounded, size: 16),
                        label: Text(
                          loading
                              ? l.splashLoading
                              : 'AUTHENTICATE VIA NEURAL',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
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
