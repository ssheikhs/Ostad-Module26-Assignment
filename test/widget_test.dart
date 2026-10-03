import 'package:flutter_test/flutter_test.dart';
import 'package:library_finder/core/data/favorite_locations_data.dart';

void main() {
  test('has at least 3 favorite locations with unique ids', () {
    expect(favoriteLocations.length, greaterThanOrEqualTo(3));
    final ids = favoriteLocations.map((l) => l.id).toSet();
    expect(ids.length, favoriteLocations.length);
  });

  test('favorite locations have valid coordinates', () {
    for (final location in favoriteLocations) {
      expect(location.latitude, inInclusiveRange(-90, 90));
      expect(location.longitude, inInclusiveRange(-180, 180));
    }
  });
}
