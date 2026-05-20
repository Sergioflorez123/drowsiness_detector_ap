import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/platform_maps.dart';
import '../../core/services/location_service.dart';
import '../../app/eye_alert_colors.dart';

/// Mini-mapa flotante (Picture-in-Picture) para la pantalla de conducción.
class DrivingMiniMap extends StatefulWidget {
  const DrivingMiniMap({super.key});

  @override
  State<DrivingMiniMap> createState() => _DrivingMiniMapState();
}

class _DrivingMiniMapState extends State<DrivingMiniMap> {
  final _location = LocationService();
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _sub;

  LatLng _target = const LatLng(4.8133, -75.6961);
  bool _hasFix = false;
  DateTime? _lastCameraMoveAt;
  LatLng? _lastCameraTarget;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. Obtener última ubicación conocida de forma opcional y segura
    try {
      final last = await _location.getLastKnown().timeout(
        const Duration(seconds: 2),
      );
      if (last != null && mounted) {
        setState(() {
          _target = LatLng(last.latitude, last.longitude);
          _hasFix = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_target, 16),
        );
      }
    } catch (e) {
      debugPrint('Error getting last known position: $e');
    }

    // 2. Escuchar el flujo de ubicación en tiempo real y actualizar el mapa
    try {
      _sub = _location.stream().listen((pos) {
        if (!mounted) return;
        final next = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _target = next;
          _hasFix = true;
        });
        _maybeMoveCamera(next);
      });
    } catch (e) {
      debugPrint('Error listening to location stream: $e');
    }

    // 3. Solicitar fijación precisa de ubicación
    unawaited(_fetchAccurateFix());
  }

  Future<void> _fetchAccurateFix() async {
    try {
      final pos = await _location.getCurrentFast().timeout(
        const Duration(seconds: 4),
      );
      if (!mounted) return;
      final next = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _target = next;
        _hasFix = true;
      });
      _maybeMoveCamera(next, force: true);
    } catch (_) {}
  }

  void _maybeMoveCamera(LatLng target, {bool force = false}) {
    final now = DateTime.now();
    final lastAt = _lastCameraMoveAt;
    final lastTarget = _lastCameraTarget;

    if (!force &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      return;
    }

    if (!force && lastTarget != null) {
      final movedMeters = Geolocator.distanceBetween(
        lastTarget.latitude,
        lastTarget.longitude,
        target.latitude,
        target.longitude,
      );
      if (movedMeters < 10) return;
    }

    _lastCameraMoveAt = now;
    _lastCameraTarget = target;
    _mapController?.animateCamera(CameraUpdate.newLatLng(target));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mapsSupportedOnDevice) {
      return const SizedBox(
        width: 148,
        height: 108,
        child: MapUnavailablePlaceholder(
          height: 108,
          message: 'GPS activo',
        ),
      );
    }

    return Container(
      width: 148,
      height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EyeAlertColors.primary.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CCFF).withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _target,
                zoom: _hasFix ? 16 : 13,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('driver'),
                  position: _target,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
              },
              onMapCreated: (c) {
                _mapController = c;
                if (_hasFix) {
                  _maybeMoveCamera(_target, force: true);
                }
              },
            ),
            if (!_hasFix)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1EE7FF),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
