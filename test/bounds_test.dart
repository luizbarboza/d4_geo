// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("bounds: Feature", () {
    expect(
        geoBounds({
          "type": "Feature",
          "geometry": {
            "type": "MultiPoint",
            "coordinates": [
              [-123, 39],
              [-122, 38]
            ]
          }
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: FeatureCollection", () {
    expect(
        geoBounds({
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [-123, 39]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [-122, 38]
              }
            }
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: GeometryCollection", () {
    expect(
        geoBounds({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [-123, 39]
            },
            {
              "type": "Point",
              "coordinates": [-122, 38]
            }
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: LineString - simple", () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [-123, 39],
            [-122, 38]
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: LineString - symmetry", () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [-30, -20],
            [130, 40]
          ]
        }),
        equals(geoBounds({
          "type": "LineString",
          "coordinates": [
            [-30, -20],
            [130, 40]
          ].reversed.toList()
        })));
  });

  test("bounds: LineString - containing coincident points", () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [-123, 39],
            [-122, 38],
            [-122, 38]
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: LineString - meridian", () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [0, 1],
            [0, 60]
          ]
        }),
        equals([
          [0, 0],
          [0, 60]
        ]));
  });

  test("bounds: LineString - equator", () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 0],
            [60, 0]
          ]
        }),
        equals([
          [0, 0],
          [60, 0]
        ]));
  });

  test(
      "bounds: LineString - containing an inflection point in the Northern hemisphere",
      () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [-45, 60],
            [45, 60]
          ]
        }),
        equals([
          [-45, 60],
          [45, 67.792345]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)).toList()).toList()));
  });

  test(
      "bounds: LineString - containing an inflection point in the Southern hemisphere",
      () {
    expect(
        geoBounds({
          "type": "LineString",
          "coordinates": [
            [-45, -60],
            [45, -60]
          ]
        }),
        [
          [-45, -67.792345],
          [45, -60]
        ].map((a) => a.map((b) => closeTo(b, 1e-6))));
  });

  test("bounds: MultiLineString", () {
    expect(
        geoBounds({
          "type": "MultiLineString",
          "coordinates": [
            [
              [-123, 39],
              [-122, 38]
            ]
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: MultiPoint - simple", () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-123, 39],
            [-122, 38]
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39]
        ]));
  });

  test("bounds: MultiPoint - two points near antimeridian", () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-179, 39],
            [179, 38]
          ]
        }),
        equals([
          [179, 38],
          [-179, 39]
        ]));
  });

  test(
      "bounds: MultiPoint - two points near antimeridian, two points near primary meridian",
      () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-179, 39],
            [179, 38],
            [-1, 0],
            [1, 0]
          ]
        }),
        equals([
          [-1, 0],
          [-179, 39]
        ]));
  });

  test(
      "bounds: MultiPoint - two points near primary meridian, two points near antimeridian",
      () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-1, 0],
            [1, 0],
            [-179, 39],
            [179, 38]
          ]
        }),
        equals([
          [-1, 0],
          [-179, 39]
        ]));
  });

  test(
      "bounds: MultiPoint - four mixed points near primary meridian and antimeridian",
      () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-1, 0],
            [-179, 39],
            [1, 0],
            [179, 38]
          ]
        }),
        equals([
          [-1, 0],
          [-179, 39]
        ]));
  });

  test("bounds: MultiPoint - three points near antimeridian", () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [178, 38],
            [179, 39],
            [-179, 37]
          ]
        }),
        equals([
          [178, 37],
          [-179, 39]
        ]));
  });

  test("bounds: MultiPoint - various points near antimeridian", () {
    expect(
        geoBounds({
          "type": "MultiPoint",
          "coordinates": [
            [-179, 39],
            [-179, 38],
            [178, 39],
            [-178, 38]
          ]
        }),
        equals([
          [178, 38],
          [-178, 39]
        ]));
  });

  test("bounds: MultiPolygon", () {
    expect(
        geoBounds({
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [-123, 39],
                [-122, 39],
                [-122, 38],
                [-123, 39]
              ],
              [
                [10, 20],
                [20, 20],
                [20, 10],
                [10, 10],
                [10, 20]
              ]
            ]
          ]
        }),
        equals([
          [-123, 10],
          [20, 39.001067]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Point", () {
    expect(
        geoBounds({
          "type": "Point",
          "coordinates": [-123, 39]
        }),
        equals([
          [-123, 39],
          [-123, 39]
        ]));
  });

  test("bounds: Polygon - simple", () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [-123, 39],
              [-122, 39],
              [-122, 38],
              [-123, 39]
            ]
          ]
        }),
        equals([
          [-123, 38],
          [-122, 39.001067]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Polygon - larger than a hemisphere, small, counter-clockwise",
      () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [10, 0],
              [10, 10],
              [0, 10],
              [0, 0]
            ]
          ]
        }),
        equals([
          [-180, -90],
          [180, 90]
        ]));
  });

  test("bounds: Polygon - larger than a hemisphere, large lat-lon rectangle",
      () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [-170, 80],
              [0, 80],
              [170, 80],
              [170, -80],
              [0, -80],
              [-170, -80],
              [-170, 80]
            ]
          ]
        }),
        equals([
          [-170, -89.119552],
          [170, 89.119552]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Polygon - larger than a hemisphere, South pole", () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [10, 80],
              [170, 80],
              [-170, 80],
              [-10, 80],
              [10, 80]
            ]
          ]
        }),
        equals([
          [-180, -90],
          [180, 88.246216]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Polygon - larger than a hemisphere, excluding both poles", () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [10, 80],
              [170, 80],
              [-170, 80],
              [-10, 80],
              [-10, 0],
              [-10, -80],
              [-170, -80],
              [170, -80],
              [10, -80],
              [10, 0],
              [10, 80]
            ]
          ]
        }),
        equals([
          [10, -88.246216],
          [-10, 88.246216]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Polygon - South pole", () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [-60, -80],
              [60, -80],
              [180, -80],
              [-60, -80]
            ]
          ]
        }),
        equals([
          [-180, -90],
          [180, -80]
        ]));
  });

  test("bounds: Polygon - ring", () {
    expect(
        geoBounds({
          "type": "Polygon",
          "coordinates": [
            [
              [-60, -80],
              [60, -80],
              [180, -80],
              [-60, -80]
            ],
            [
              [-60, -89],
              [180, -89],
              [60, -89],
              [-60, -89]
            ]
          ]
        }),
        equals([
          [-180, -89.499961],
          [180, -80]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))));
  });

  test("bounds: Sphere", () {
    expect(
        geoBounds({"type": "Sphere"}),
        equals([
          [-180, -90],
          [180, 90]
        ]));
  });

  test("bounds: NestedCollection", () {
    expect(
        geoBounds({
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "GeometryCollection",
                "geometries": [
                  {
                    "type": "Point",
                    "coordinates": [-120, 47]
                  },
                  {
                    "type": "Point",
                    "coordinates": [-119, 46]
                  }
                ]
              }
            }
          ]
        }),
        equals([
          [-120, 46],
          [-119, 47]
        ]));
  });

  test("bounds: null geometries - Feature", () {
    final b = geoBounds({"type": "Feature", "geometry": null});
    expect(b[0][0], isNaN);
    expect(b[0][1], isNaN);
    expect(b[1][0], isNaN);
    expect(b[1][1], isNaN);
  });

  test("bounds: null geometries - MultiPoint", () {
    final b =
        geoBounds({"type": "MultiPoint", "coordinates": <Iterable<num>>[]});
    expect(b[0][0], isNaN);
    expect(b[0][1], isNaN);
    expect(b[1][0], isNaN);
    expect(b[1][1], isNaN);
  });

  test("bounds: null geometries - MultiLineString", () {
    final b = geoBounds({
      "type": "MultiLineString",
      "coordinates": <Iterable<Iterable<num>>>[]
    });
    expect(b[0][0], isNaN);
    expect(b[0][1], isNaN);
    expect(b[1][0], isNaN);
    expect(b[1][1], isNaN);
  });

  test("bounds: null geometries - MultiPolygon", () {
    final b = geoBounds({
      "type": "MultiPolygon",
      "coordinates": <Iterable<Iterable<Iterable<num>>>>[]
    });
    expect(b[0][0], isNaN);
    expect(b[0][1], isNaN);
    expect(b[1][0], isNaN);
    expect(b[1][1], isNaN);
  });
}
