import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get current location as "lat,lng" string
  static Future<String?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return '${position.latitude},${position.longitude}';
    } catch (e) {
      print('❌ Location error: $e');
      return null;
    }
  }

  /// Convert lat,lng string to human-readable address (optional)
  static Future<String?> getAddressFromLatLng(String latLng) async {
    // You can integrate Google Geocoding API here if needed
    return latLng; // For now, return coordinates
  }
}
