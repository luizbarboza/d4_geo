// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

final equirectangular = geoEquirectangular()
  ..scale = 900 / pi
  ..precision = 0;

List<double> testCentroid(GeoProjection projection, Map object) =>
    (GeoPath()..transform = projection).centroid(object);

void main() {
  test("geoPath.centroid(…) of a point", () {
    expect(
        testCentroid(equirectangular, {
          "type": "Point",
          "coordinates": [0, 0]
        }),
        equals([480, 250]));
  });

  test("geoPath.centroid(…) of an empty multipoint", () {
    expect(
        testCentroid(
            equirectangular, {"type": "MultiPoint", "coordinates": []}),
        everyElement(isNaN));
  });

  test("geoPath.centroid(…) of a singleton multipoint", () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiPoint",
          "coordinates": [
            [0, 0]
          ]
        }),
        equals([480, 250]));
  });

  test("geoPath.centroid(…) of a multipoint with two points", () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiPoint",
          "coordinates": [
            [-122, 37],
            [-74, 40]
          ]
        }),
        equals([-10, 57.5]));
  });

  test("geoPath.centroid(…) of an empty linestring", () {
    expect(
        testCentroid(
            equirectangular, {"type": "LineString", "coordinates": []}),
        everyElement(isNaN));
  });

  test("geoPath.centroid(…) of a linestring with two points", () {
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [100, 0],
            [0, 0]
          ]
        }),
        equals([730, 250]));
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [100, 0],
            [101, 0]
          ]
        }),
        equals([732.5, 250]));
  });

  test("geoPath.centroid(…) of a linestring with two points, one unique", () {
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [-122, 37],
            [-122, 37]
          ]
        }),
        equals([-130, 65]));
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [-74, 40],
            [-74, 40]
          ]
        }),
        equals([110, 50]));
  });

  test("geoPath.centroid(…) of a linestring with three points; two unique", () {
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [-122, 37],
            [-74, 40],
            [-74, 40]
          ]
        }),
        equals([-10, 57.5]));
  });

  test("geoPath.centroid(…) of a linestring with three points", () {
    expect(
        testCentroid(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [-122, 37],
            [-74, 40],
            [-100, 0]
          ]
        }),
        equals([17.389135, 103.563545].map((a) => closeTo(a, 1e-6))));
  });

  test("geoPath.centroid(…) of a multilinestring", () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiLineString",
          "coordinates": [
            [
              [100, 0],
              [0, 0]
            ],
            [
              [-10, 0],
              [0, 0]
            ]
          ]
        }),
        equals([705, 250]));
  });

  test("geoPath.centroid(…) of a single-ring polygon", () {
    expect(
        testCentroid(equirectangular, {
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
        equals([982.5, 247.5]));
  });

  test("geoPath.centroid(…) of a zero-area polygon", () {
    expect(
        testCentroid(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [1, 0],
              [2, 0],
              [3, 0],
              [1, 0]
            ]
          ]
        }),
        equals([490, 250]));
  });

  test("geoPath.centroid(…) of a polygon with two rings, one with zero area",
      () {
    expect(
        testCentroid(equirectangular, {
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
              [100.1, 0],
              [100.2, 0],
              [100.3, 0],
              [100.1, 0]
            ]
          ]
        }),
        equals([982.5, 247.5]));
  });

  test(
      "geoPath.centroid(…) of a polygon with clockwise exterior and anticlockwise interior",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [-2, -2],
              [2, -2],
              [2, 2],
              [-2, 2],
              [-2, -2]
            ].reversed.toList(),
            [
              [0, -1],
              [1, -1],
              [1, 1],
              [0, 1],
              [0, -1]
            ]
          ]
        }),
        equals([479.642857, 250].map((a) => closeTo(a, 1e-6))));
  });

  test("geoPath.centroid(…) of an empty multipolygon", () {
    expect(
        testCentroid(
            equirectangular, {"type": "MultiPolygon", "coordinates": []}),
        everyElement(isNaN));
  });

  test("geoPath.centroid(…) of a singleton multipolygon", () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [100, 0],
                [100, 1],
                [101, 1],
                [101, 0],
                [100, 0]
              ]
            ]
          ]
        }),
        equals([982.5, 247.5]));
  });

  test("geoPath.centroid(…) of a multipolygon with two polygons", () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [100, 0],
                [100, 1],
                [101, 1],
                [101, 0],
                [100, 0]
              ]
            ],
            [
              [
                [0, 0],
                [1, 0],
                [1, -1],
                [0, -1],
                [0, 0]
              ]
            ]
          ]
        }),
        equals([732.5, 250]));
  });

  test("geoPath.centroid(…) of a multipolygon with two polygons, one zero area",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [100, 0],
                [100, 1],
                [101, 1],
                [101, 0],
                [100, 0]
              ]
            ],
            [
              [
                [0, 0],
                [1, 0],
                [2, 0],
                [0, 0]
              ]
            ]
          ]
        }),
        equals([982.5, 247.5]));
  });

  test("geoPath.centroid(…) of a geometry collection with a single point", () {
    expect(
        testCentroid(equirectangular, {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            }
          ]
        }),
        equals([480, 250]));
  });

  test(
      "geoPath.centroid(…) of a geometry collection with a point and a linestring",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "LineString",
              "coordinates": [
                [179, 0],
                [180, 0]
              ]
            },
            {
              "type": "Point",
              "coordinates": [0, 0]
            }
          ]
        }),
        equals([1377.5, 250]));
  });

  test(
      "geoPath.centroid(…) of a geometry collection with a point, linestring and polygon",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "coordinates": [
                [
                  [-180, 0],
                  [-180, 1],
                  [-179, 1],
                  [-179, 0],
                  [-180, 0]
                ]
              ]
            },
            {
              "type": "LineString",
              "coordinates": [
                [179, 0],
                [180, 0]
              ]
            },
            {
              "type": "Point",
              "coordinates": [0, 0]
            }
          ]
        }),
        equals([-417.5, 247.5]));
  });

  test("geoPath.centroid(…) of a feature collection with a point", () {
    expect(
        testCentroid(equirectangular, {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [0, 0]
              }
            }
          ]
        }),
        equals([480, 250]));
  });

  test(
      "geoPath.centroid(…) of a feature collection with a point and a line string",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [
                  [179, 0],
                  [180, 0]
                ]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [0, 0]
              }
            }
          ]
        }),
        equals([1377.5, 250]));
  });

  test(
      "geoPath.centroid(…) of a feature collection with a point, line string and polygon",
      () {
    expect(
        testCentroid(equirectangular, {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Polygon",
                "coordinates": [
                  [
                    [-180, 0],
                    [-180, 1],
                    [-179, 1],
                    [-179, 0],
                    [-180, 0]
                  ]
                ]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [
                  [179, 0],
                  [180, 0]
                ]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [0, 0]
              }
            }
          ]
        }),
        equals([-417.5, 247.5]));
  });

  test("geoPath.centroid(…) of a sphere", () {
    expect(
        testCentroid(equirectangular, {"type": "Sphere"}), equals([480, 250]));
  });
}
