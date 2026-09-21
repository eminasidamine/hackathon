Future<(double, double)> getBrowserPosition() {
  throw Exception(
    "Automatic location isn't available on this build. Type your address by hand instead.",
  );
}

Future<List<Map<String, dynamic>>> searchPlacesRaw(String query) {
  throw Exception(
      "Place search isn't available on this build. Type your address by hand instead.");
}
