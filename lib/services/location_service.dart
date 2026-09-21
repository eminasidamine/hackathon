import 'dart:math' as math;
import 'location/location_provider_stub.dart'
    if (dart.library.html) 'location/location_provider_web.dart';

class DeviceLocation {
  final double latitude;
  final double longitude;

  const DeviceLocation({required this.latitude, required this.longitude});

  String get short =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

class PlaceResult {
  final String label;
  final double lat;
  final double lng;

  const PlaceResult(
      {required this.label, required this.lat, required this.lng});
}

class LocationService {
  Future<DeviceLocation> currentPosition() async {
    final (lat, lng) = await getBrowserPosition();
    return DeviceLocation(latitude: lat, longitude: lng);
  }

  Future<List<PlaceResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];
    final raw = await searchPlacesRaw(trimmed);
    return raw
        .map((m) {
          final lat = double.tryParse('${m['lat']}');
          final lng = double.tryParse('${m['lon']}');
          final label = m['display_name'] as String?;
          if (lat == null || lng == null || label == null || label.isEmpty)
            return null;
          return PlaceResult(label: label, lat: lat, lng: lng);
        })
        .whereType<PlaceResult>()
        .toList();
  }

  static double distanceKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const r = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return double.parse((r * c).toStringAsFixed(2));
  }

  static double _radians(double deg) => deg * (math.pi / 180);
}
