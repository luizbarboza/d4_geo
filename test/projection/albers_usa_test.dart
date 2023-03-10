// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test(
      "albersUsa(point) and albersUsa.invert(point) returns the expected result",
      () {
    final albersUsa = GeoAlbersUsa(),
        projectionEqual = ProjectionEqual(albersUsa, 0.1);
    expect([
      [-122.4194, 37.7749],
      [107.4, 214.1]
    ], projectionEqual); // San Francisco, CA
    expect([
      [-74.0059, 40.7128],
      [794.6, 176.5]
    ], projectionEqual); // New York, NY
    expect([
      [-95.9928, 36.1540],
      [488.8, 298.0]
    ], projectionEqual); // Tulsa, OK
    expect([
      [-149.9003, 61.2181],
      [171.2, 446.9]
    ], projectionEqual); // Anchorage, AK
    expect([
      [-157.8583, 21.3069],
      [298.5, 451.0]
    ], projectionEqual); // Honolulu, HI
    expect(
        albersUsa.forward([2.3522, 48.8566]), [isNaN, isNaN]); // Paris, France
  });
}
