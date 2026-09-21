import 'dart:html' as html;
import 'dart:convert';

Future<(double, double)> getBrowserPosition() async {
  try {
    final geo = html.window.navigator.geolocation;
    final pos = await geo.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 15),
    );
    final coords = pos.coords;
    if (coords == null || coords.latitude == null || coords.longitude == null) {
      throw Exception(
          "Could not read your position. Type your address by hand instead.");
    }
    return (coords.latitude!.toDouble(), coords.longitude!.toDouble());
  } on html.PositionError catch (e) {
    final reason = switch (e.code) {
      1 => "location access was denied",
      2 => "your position isn't available right now",
      3 => "it took too long to get a location fix",
      _ => "an unknown error",
    };
    throw Exception(
        "Couldn't get your location ($reason). Type your address by hand instead.");
  } catch (_) {
    throw Exception(
      "Location isn't available in this browser or on this connection. Type your address by hand instead.",
    );
  }
}

Future<List<Map<String, dynamic>>> searchPlacesRaw(String query) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'format': 'json',
    'q': query,
    'addressdetails': '0',
    'limit': '6',
  });
  try {
    final response = await html.HttpRequest.getString(uri.toString());
    final decoded = jsonDecode(response);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  } catch (_) {
    throw Exception(
        "Couldn't search for that place. Check your connection and try again.");
  }
}
