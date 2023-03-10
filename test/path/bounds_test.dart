import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

final equirectangular = geoEquirectangular()
  ..scale = 900 / pi
  ..precision = 0;

List<List<num>> testBounds(GeoProjection projection, Map object) =>
    (GeoPath()..transform = projection).bounds(object);

void main() {
  test("geoPath.bounds(…) of a polygon with no holes", () {
    expect(
        testBounds(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [100, 0],
              [100, 1],
              [101, 1],
              [101, 0],
              [100, 0]
            ]
          ]
        }),
        [
          [980, 245],
          [985, 250]
        ]);
  });

  test("geoPath.bounds(…) of a polygon with holes", () {
    expect(
        testBounds(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [100, 0],
              [100, 1],
              [101, 1],
              [101, 0],
              [100, 0]
            ],
            [
              [100.2, 0.2],
              [100.8, 0.2],
              [100.8, 0.8],
              [100.2, 0.8],
              [100.2, 0.2]
            ]
          ]
        }),
        [
          [980, 245],
          [985, 250]
        ]);
  });

  test("geoPath.bounds(…) of a sphere", () {
    expect(testBounds(equirectangular, {"type": "Sphere"}), [
      [-420, -200],
      [1380, 700]
    ]);
  });
}
