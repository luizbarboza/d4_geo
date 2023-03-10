import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

final equirectangular = geoEquirectangular()
  ..scale = 900 / pi
  ..precision = 0;

double testArea(GeoProjection projection, Map object) =>
    (GeoPath()..transform = projection).area(object);

void main() {
  test("geoPath.area(…) of a polygon with no holes", () {
    expect(
        testArea(equirectangular, {
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
        equals(25));
  });

  test("geoPath.area(…) of a polygon with holes", () {
    expect(
        testArea(equirectangular, {
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
        equals(16));
  });

  test("geoPath.area(…) of a sphere", () {
    expect(
        testArea(equirectangular, {
          "type": "Sphere",
        }),
        equals(1620000));
  });
}
