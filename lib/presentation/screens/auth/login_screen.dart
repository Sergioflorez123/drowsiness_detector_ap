import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
  bool _scanningFace = false;

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

  InputImage? _toInputImage(CameraImage image, CameraController controller) {
    final sensorOrientation = controller.description.sensorOrientation;
    InputImageRotation rotation = InputImageRotation.rotation0deg;
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;
    final buffer = WriteBuffer();
    for (final p in image.planes) {
      buffer.putUint8List(p.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> _scanFaceAndLogin() async {
    final l = AppLocalizations.of(context)!;
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorLogin)),
      );
      return;
    }

    setState(() => _scanningFace = true);
    CameraController? cam;
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableTracking: false,
      ),
    );

    bool detected = false;
    bool processing = false;
    bool dialogOpen = false;
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      cam = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await cam.initialize();
      final completer = Completer<bool>();
      await cam.startImageStream((image) async {
        if (processing || detected || !mounted) return;
        processing = true;
        try {
          final input = _toInputImage(image, cam!);
          if (input == null) return;
          final faces = await detector.processImage(input);
          if (faces.isNotEmpty) {
            detected = true;
            if (!completer.isCompleted) completer.complete(true);
            if (dialogOpen && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        } catch (_) {
          // ignore broken frame
        } finally {
          processing = false;
        }
      });

      dialogOpen = true;
      Timer(const Duration(seconds: 8), () {
        if (!completer.isCompleted) completer.complete(false);
        if (dialogOpen && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l.loginTitle),
            content: SizedBox(
              width: 260,
              height: 220,
              child: cam!.value.isInitialized ? CameraPreview(cam) : const SizedBox(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l.cancel),
              ),
            ],
          );
        },
      );
      dialogOpen = false;

      final okFace = await completer.future;
      if (okFace && detected) {
        await _submit();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'es'
                  ? 'No se detecto rostro. Intenta de nuevo.'
                  : 'No face detected. Try again.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'es'
                  ? 'No se pudo abrir camara frontal.'
                  : 'Could not open front camera.',
            ),
          ),
        );
      }
    } finally {
      try {
        await cam?.stopImageStream();
      } catch (_) {}
      await cam?.dispose();
      await detector.close();
      if (mounted) {
        setState(() => _scanningFace = false);
      }
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
                        onPressed: (loading || _scanningFace) ? null : _scanFaceAndLogin,
                        child: _scanningFace
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
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
                        obscureText: !_showPassword,
                        style: const TextStyle(color: Color(0xFFD7F8FF)),
                        decoration: InputDecoration(
                          labelText: 'Passkey',
                          labelStyle: const TextStyle(color: Color(0xFF72BCD0)),
                          prefixIcon: const Icon(
                            Icons.key_outlined,
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
