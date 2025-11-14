import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current location as human-readable address string
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

      // Convert coordinates to address
      String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return address;
    } catch (e) {
      print('❌ Location error: $e');
      return null;
    }
  }

  /// Convert coordinates to human-readable address
  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return '$latitude, $longitude'; // Fallback to coordinates
      }

      Placemark place = placemarks.first;

      // Build address string from available components
      List<String> addressParts = [];

      // Add street/thoroughfare
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }

      // Add subLocality (neighborhood/area)
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }

      // Add locality (city/town)
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }

      // Add administrativeArea (state/province)
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }

      // Add country
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      // Add postal code if available
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        addressParts.add(place.postalCode!);
      }

      // Join with comma separator
      String fullAddress = addressParts.join(', ');

      // If no address components found, return coordinates
      if (fullAddress.isEmpty) {
        return '$latitude, $longitude';
      }

      return fullAddress;
    } catch (e) {
      print('❌ Geocoding error: $e');
      // Return coordinates as fallback
      return '$latitude, $longitude';
    }
  }

  /// Get compact address (street, city, country)
  static Future<String> getCompactAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return '$latitude, $longitude';
      }

      Placemark place = placemarks.first;

      List<String> addressParts = [];

      // Street
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }

      // City
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }

      // Country
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      return addressParts.isEmpty
          ? '$latitude, $longitude'
          : addressParts.join(', ');
    } catch (e) {
      print('❌ Geocoding error: $e');
      return '$latitude, $longitude';
    }
  }

  /// Get coordinates only (for backup/logging)
  static Future<String?> getCoordinatesOnly() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

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
}
