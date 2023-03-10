import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("geoPath.measure(…) of a Point", () {
    expect(
        GeoPath().measure({
          "type": "Point",
          "coordinates": [0, 0]
        }),
        equals(0));
  });

  test("geoPath.measure(…) of a MultiPoint", () {
    expect(
        GeoPath().measure({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [0, 1],
            [1, 1],
            [1, 0]
          ]
        }),
        equals(0));
  });

  test("geoPath.measure(…) of a LineString", () {
    expect(
        GeoPath().measure({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [0, 1],
            [1, 1],
            [1, 0]
          ]
        }),
        equals(3));
  });

  test("geoPath.measure(…) of a MultiLineString", () {
    expect(
        GeoPath().measure({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, 0],
              [0, 1],
              [1, 1],
              [1, 0]
            ]
          ]
        }),
        equals(3));
  });

  test("geoPath.measure(…) of a Polygon", () {
    expect(
        GeoPath().measure({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [0, 1],
              [1, 1],
              [1, 0],
              [0, 0]
            ]
          ]
        }),
        equals(4));
  });

  test("geoPath.measure(…) of a Polygon with a hole", () {
    expect(
        GeoPath().measure({
          "type": "Polygon",
          "coordinates": [
            [
              [-1, -1],
              [-1, 2],
              [2, 2],
              [2, -1],
              [-1, -1]
            ],
            [
              [0, 0],
              [1, 0],
              [1, 1],
              [0, 1],
              [0, 0]
            ]
          ]
        }),
        equals(16));
  });

  test("geoPath.measure(…) of a MultiPolygon", () {
    expect(
        GeoPath().measure({
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [-1, -1],
                [-1, 2],
                [2, 2],
                [2, -1],
                [-1, -1]
              ]
            ],
            [
              [
                [0, 0],
                [0, 1],
                [1, 1],
                [1, 0],
                [0, 0]
              ]
            ]
          ]
        }),
        equals(16));
  });
}
