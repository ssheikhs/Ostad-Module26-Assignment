import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A place the user has saved as a favorite.
class FavoriteLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  /// Convenience getter for use with Google Maps.
  LatLng get latLng => LatLng(latitude, longitude);

  /// Unique id for this location's map marker.
  MarkerId get markerId => MarkerId('favorite_$id');

  @override
  String toString() =>
      'FavoriteLocation(id: $id, name: $name, lat: $latitude, lng: $longitude)';
}
