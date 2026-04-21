import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:drowsiness_detector_ap/core/services/location_service.dart';
import 'package:drowsiness_detector_ap/l10n/app_localizations.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final _location = LocationService();
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _sub;

  LatLng _target = const LatLng(4.65, -74.05);
  bool _hasFix = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final l = AppLocalizations.of(context)!;

    try {
      final last = await _location.getLastKnown();
      if (!mounted) return;
      if (last != null) {
        setState(() {
          _target = LatLng(last.latitude, last.longitude);
          _hasFix = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_target, 15.5),
        );
      }

      final fresh = await _location.getCurrent();
      if (!mounted) return;
      setState(() {
        _target = LatLng(fresh.latitude, fresh.longitude);
        _hasFix = true;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_target, 16.2),
      );

      _sub = _location.stream().listen((pos) {
        if (!mounted) return;
        setState(() {
          _target = LatLng(pos.latitude, pos.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_target),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.mapPermission)),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.mapTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _target,
              zoom: _hasFix ? 15.5 : 4.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('me'),
                position: _target,
                infoWindow: InfoWindow(title: l.appTitle),
              ),
            },
            onMapCreated: (c) => _mapController = c,
          ),
          if (!_hasFix && !_permissionDenied)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: scheme.surface.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.mapLocating,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
