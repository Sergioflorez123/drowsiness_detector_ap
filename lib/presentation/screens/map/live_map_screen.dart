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
  DateTime? _lastCameraMoveAt;
  LatLng? _lastCameraTarget;

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
      _sub = _location.stream().listen((pos) {
        if (!mounted) return;
        setState(() {
          _target = LatLng(pos.latitude, pos.longitude);
          _hasFix = true;
        });
        _maybeMoveCamera(_target, zoom: 16.0);
      });

      // Do not block UI waiting for high-accuracy fix.
      unawaited(_fetchAccurateFix());
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

  Future<void> _fetchAccurateFix() async {
    try {
      final fast = await _location.getCurrentFast().timeout(
        const Duration(seconds: 3),
      );
      if (!mounted) return;
      final quick = LatLng(fast.latitude, fast.longitude);
      setState(() {
        _target = quick;
        _hasFix = true;
      });
      _maybeMoveCamera(quick, zoom: 15.8, force: true);

      final fresh = await _location.getCurrent().timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final next = LatLng(fresh.latitude, fresh.longitude);
      setState(() {
        _target = next;
        _hasFix = true;
      });
      _maybeMoveCamera(next, zoom: 16.2, force: true);
    } catch (_) {
      // Keep last known or streaming position silently.
    }
  }

  void _maybeMoveCamera(
    LatLng target, {
    double? zoom,
    bool force = false,
  }) {
    final now = DateTime.now();
    final lastAt = _lastCameraMoveAt;
    final lastTarget = _lastCameraTarget;

    if (!force && lastAt != null && now.difference(lastAt) < const Duration(seconds: 2)) {
      return;
    }

    if (!force && lastTarget != null) {
      final movedMeters = Geolocator.distanceBetween(
        lastTarget.latitude,
        lastTarget.longitude,
        target.latitude,
        target.longitude,
      );
      if (movedMeters < 15) return;
    }

    _lastCameraMoveAt = now;
    _lastCameraTarget = target;
    if (zoom != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    } else {
      _mapController?.animateCamera(CameraUpdate.newLatLng(target));
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
            onMapCreated: (c) {
              _mapController = c;
              if (_hasFix) {
                _maybeMoveCamera(_target, zoom: 16.0, force: true);
              }
            },
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
