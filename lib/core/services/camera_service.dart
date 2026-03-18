import 'package:flutter/material.dart';

/// Implementación “stub” para evitar plugins que requieran symlinks en Windows.
/// Cuando tengas symlinks habilitados, esto se reemplaza por `camera` real.
class CameraService {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _initialized = true;
  }

  Widget buildPreview() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        'Camera preview (pendiente habilitar symlinks)',
        textAlign: TextAlign.center,
      ),
    );
  }

  void dispose() {}
}

