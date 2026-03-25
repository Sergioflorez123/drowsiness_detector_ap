import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/location_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final location = LocationService();
  LatLng? current;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      // 1. Fuerza la petición de permisos de GPS si no los tenía
      final pos = await location.getCurrent();
      if (!mounted) return;
      setState(() {
        current = LatLng(pos.latitude, pos.longitude);
      });
      
      // 2. Comienza a seguir en vivo sólo si hay permisos correctos
      _sub = location.stream().listen((newPos) {
        if (mounted) {
          setState(() {
            current = LatLng(newPos.latitude, newPos.longitude);
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes otorgar el permiso de Ubicación/GPS para ver el mapa.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Live Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: current!,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('me'),
            position: current!,
          ),
        },
      ),
    );
  }
}
