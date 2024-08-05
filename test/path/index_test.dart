// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'test_conext.dart';

final equirectangular = geoEquirectangular()
  ..scale = 900 / pi
  ..precision = 0;

List<Map>? testPath(GeoProjection? projection, Map object) {
  final context = TestContext();

  (GeoPath()
    ..transform = projection
    ..context = context)(object);

  return context.result();
}

void main() {
  test("geoPath.projection() defaults to null", () {
    final path = GeoPath();
    expect(path.transform, equals(null));
  });

  test("geoPath.context() defaults to null", () {
    final path = GeoPath();
    expect(path.context, equals(null));
  });

  test("geoPath(projection) sets the initial projection", () {
    final projection = geoAlbers(), path = GeoPath(projection);
    expect(path.transform, equals(projection));
  });

  test("geoPath(projection, context) sets the initial projection and context",
      () {
    final context = TestContext(),
        projection = geoAlbers(),
        path = GeoPath(projection, context);
    expect(path.transform, equals(projection));
    expect(path.context, equals(context));
  });

  test("geoPath(Point) renders a point", () {
    expect(
        testPath(equirectangular, {
          "type": "Point",
          "coordinates": [-63, 18]
        }),
        equals([
          {"type": "moveTo", "x": 170, "y": 160},
          {"type": "arc", "x": 165, "y": 160, "r": 4.5}
        ]));
  });

  test("geoPath(MultiPoint) renders a point", () {
    expect(
        testPath(equirectangular, {
          "type": "MultiPoint",
          "coordinates": [
            [-63, 18],
            [-62, 18],
            [-62, 17]
          ]
        }),
        equals([
          {"type": "moveTo", "x": 170, "y": 160},
          {"type": "arc", "x": 165, "y": 160, "r": 4.5},
          {"type": "moveTo", "x": 175, "y": 160},
          {"type": "arc", "x": 170, "y": 160, "r": 4.5},
          {"type": "moveTo", "x": 175, "y": 165},
          {"type": "arc", "x": 170, "y": 165, "r": 4.5}
        ]));
  });

  test("geoPath(LineString) renders a line string", () {
    expect(
        testPath(equirectangular, {
          "type": "LineString",
          "coordinates": [
            [-63, 18],
            [-62, 18],
            [-62, 17]
          ]
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165}
        ]));
  });

  test("geoPath(Polygon) renders a polygon", () {
    expect(
        testPath(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [-63, 18],
              [-62, 18],
              [-62, 17],
              [-63, 18]
            ]
          ]
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165},
          {"type": "closePath"}
        ]));
  });

  test("geoPath(GeometryCollection) renders a geometry collection", () {
    expect(
        testPath(equirectangular, {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "coordinates": [
                [
                  [-63, 18],
                  [-62, 18],
                  [-62, 17],
                  [-63, 18]
                ]
              ]
            }
          ]
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165},
          {"type": "closePath"}
        ]));
  });

  test("geoPath(Feature) renders a feature", () {
    expect(
        testPath(equirectangular, {
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [-63, 18],
                [-62, 18],
                [-62, 17],
                [-63, 18]
              ]
            ]
          }
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165},
          {"type": "closePath"}
        ]));
  });

  test("geoPath(FeatureCollection) renders a feature collection", () {
    expect(
        testPath(equirectangular, {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Polygon",
                "coordinates": [
                  [
                    [-63, 18],
                    [-62, 18],
                    [-62, 17],
                    [-63, 18]
                  ]
                ]
              }
            }
          ]
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165},
          {"type": "closePath"}
        ]));
  });

  test("geoPath(…) wraps longitudes outside of ±180°", () {
    expect(
        testPath(equirectangular, {
          "type": "Point",
          "coordinates": [180 + 1e-6, 0]
        }),
        equals([
          {"type": "moveTo", "x": -415, "y": 250},
          {"type": "arc", "x": -420, "y": 250, "r": 4.5}
        ]));
  });

  test("geoPath(…) observes the correct winding order of a tiny polygon", () {
    expect(
        testPath(equirectangular, {
          "type": "Polygon",
          "coordinates": [
            [
              [-0.06904102953339501, 0.346043661846373],
              [-6.725674252975136e-15, 0.3981303360336475],
              [-6.742247658534323e-15, -0.08812465346531581],
              [-0.17301258217724075, -0.12278150669440671],
              [-0.06904102953339501, 0.346043661846373]
            ]
          ]
        }),
        equals([
          {"type": "moveTo", "x": 480, "y": 248},
          {"type": "lineTo", "x": 480, "y": 248},
          {"type": "lineTo", "x": 480, "y": 250},
          {"type": "lineTo", "x": 479, "y": 251},
          {"type": "closePath"}
        ]));
  });

  test("geoPath.projection(null)(…) does not transform coordinates", () {
    expect(
        testPath(null, {
          "type": "Polygon",
          "coordinates": [
            [
              [-63, 18],
              [-62, 18],
              [-62, 17],
              [-63, 18]
            ]
          ]
        }),
        equals([
          {"type": "moveTo", "x": -63, "y": 18},
          {"type": "lineTo", "x": -62, "y": 18},
          {"type": "lineTo", "x": -62, "y": 17},
          {"type": "closePath"}
        ]));
  });

  test("geoPath.context(null)(null) returns null", () {
    final path = GeoPath();
    expect(path(), equals(null));
    // ignore: avoid_redundant_argument_values
    expect(path(null), equals(null));
    //expect(path(undefined), equals(null));
  });

  test("geoPath.context(null)(Unknown) returns null", () {
    final path = GeoPath();
    expect(path({"type": "Unknown"}), equals(null));
    expect(path({"type": "__proto__"}), equals(null));
  });

  test(
      "geoPath(LineString) then geoPath(Point) does not treat the point as part of a line",
      () {
    final context = TestContext(),
        path = GeoPath()
          ..transform = equirectangular
          ..context = context;
    List<Map> testPath(Map object) {
      path(object);
      return context.result();
    }

    expect(
        testPath({
          "type": "LineString",
          "coordinates": [
            [-63, 18],
            [-62, 18],
            [-62, 17]
          ]
        }),
        equals([
          {"type": "moveTo", "x": 165, "y": 160},
          {"type": "lineTo", "x": 170, "y": 160},
          {"type": "lineTo", "x": 170, "y": 165}
        ]));
    expect(
        testPath({
          "type": "Point",
          "coordinates": [-63, 18]
        }),
        equals([
          {"type": "moveTo", "x": 170, "y": 160},
          {"type": "arc", "x": 165, "y": 160, "r": 4.5}
        ]));
  });
}
