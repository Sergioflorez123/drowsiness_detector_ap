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
    _sub = location.stream().listen((pos) {
      if (mounted) {
        setState(() {
          current = LatLng(pos.latitude, pos.longitude);
        });
      }
    });
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
