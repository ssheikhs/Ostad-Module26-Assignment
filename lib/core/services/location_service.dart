import 'package:geolocator/geolocator.dart';

/// Thrown when the device location cannot be obtained.
class LocationException implements Exception {
  final String message;

  /// True when the user must fix things in system/app settings.
  final bool openSettings;
  final bool openLocationSettings;

  const LocationException(
    this.message, {
    this.openSettings = false,
    this.openLocationSettings = false,
  });

  @override
  String toString() => message;
}

/// Wraps [Geolocator] and handles service + permission checks.
class LocationService {
  const LocationService();

  /// Returns true if location permission is already granted
  /// (does not prompt the user).
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Checks that location services are on, asks for permission if needed,
  /// then returns the device's current position.
  Future<Position> getCurrentPosition() async {
    // 1. Is the GPS / location service turned on?
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please turn on GPS.',
        openLocationSettings: true,
      );
    }

    // 2. Do we have permission? If not, ask for it.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it from app settings.',
        openSettings: true,
      );
    }

    // 3. Get latitude & longitude from the device.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Fall back to the last known fix (helpful on emulators).
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw const LocationException(
        'Could not get your location. On an emulator, set a location in '
        'Extended Controls > Location and try again.',
      );
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
