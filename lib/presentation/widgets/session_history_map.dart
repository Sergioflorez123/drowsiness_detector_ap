import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/platform_maps.dart';
import '../../domain/entities/driving_session_record.dart';

/// Mapa de una sesión con marcadores de eventos de somnolencia.
class SessionHistoryMap extends StatefulWidget {
  const SessionHistoryMap({
    super.key,
    required this.points,
    this.height = 200,
  });

  final List<SessionMapPoint> points;
  final double height;

  @override
  State<SessionHistoryMap> createState() => _SessionHistoryMapState();
}

class _SessionHistoryMapState extends State<SessionHistoryMap> {
  GoogleMapController? _controller;

  static const _defaultTarget = LatLng(4.8133, -75.6961);

  LatLng get _center {
    if (widget.points.isEmpty) return _defaultTarget;
    final p = widget.points.first;
    return LatLng(p.latitude, p.longitude);
  }

  Set<Marker> get _markers {
    return widget.points.asMap().entries.map((e) {
      final p = e.value;
      return Marker(
        markerId: MarkerId('pt_${e.key}'),
        position: LatLng(p.latitude, p.longitude),
        icon: _markerHue(p.severity),
        infoWindow: InfoWindow(
          title: p.severity.toUpperCase(),
          snippet: _formatTime(p.at),
        ),
      );
    }).toSet();
  }

  BitmapDescriptor _markerHue(String severity) {
    switch (severity) {
      case 'critical':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'drowsy':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'tired':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mapsSupportedOnDevice) {
      return MapUnavailablePlaceholder(
        height: widget.height,
        message: widget.points.isEmpty
            ? 'Sin eventos de somnolencia en esta ruta'
            : '${widget.points.length} punto(s) GPS registrados',
      );
    }

    final hasPoints = widget.points.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: hasPoints ? 14.5 : 11,
              ),
              markers: _markers,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              liteModeEnabled: false,
              onMapCreated: (c) {
                _controller = c;
                if (hasPoints && widget.points.length > 1) {
                  _fitBounds();
                }
              },
            ),
            if (!hasPoints)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: Text(
                      'Sin eventos de somnolencia en esta ruta',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fitBounds() async {
    if (_controller == null || widget.points.length < 2) return;

    double minLat = widget.points.first.latitude;
    double maxLat = minLat;
    double minLng = widget.points.first.longitude;
    double maxLng = minLng;

    for (final p in widget.points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }
}
