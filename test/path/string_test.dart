// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

final equirectangular = geoEquirectangular()
  ..scale = 900 / pi
  ..precision = 0;

String? testPath(GeoProjection projection, Map object) =>
    normalizePath((GeoPath()..transform = projection)(object) as String);

void main() {
  test("geoPath(Point) renders a point", () {
    expect(
        testPath(equirectangular, {
          "type": "Point",
          "coordinates": [-63, 18]
        }),
        equals(
            "M165,160m0,4.500000a4.500000,4.500000 0 1,1 0,-9a4.500000,4.500000 0 1,1 0,9z"));
  });

  test("geoPath.pointRadius(radius)(Point) renders a point of the given radius",
      () {
    expect(
        normalizePath((GeoPath()
          ..transform = equirectangular
          ..pointRadius = ((_) => 10))({
          "type": "Point",
          "coordinates": [-63, 18]
        }) as String),
        equals("M165,160m0,10a10,10 0 1,1 0,-20a10,10 0 1,1 0,20z"));
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
        equals(
            "M165,160m0,4.500000a4.500000,4.500000 0 1,1 0,-9a4.500000,4.500000 0 1,1 0,9zM170,160m0,4.500000a4.500000,4.500000 0 1,1 0,-9a4.500000,4.500000 0 1,1 0,9zM170,165m0,4.500000a4.500000,4.500000 0 1,1 0,-9a4.500000,4.500000 0 1,1 0,9z"));
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
        equals("M165,160L170,160L170,165"));
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
        equals("M165,160L170,160L170,165Z"));
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
        equals("M165,160L170,160L170,165Z"));
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
        equals("M165,160L170,160L170,165Z"));
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
        equals("M165,160L170,160L170,165Z"));
  });

  test(
      "geoPath(LineString) then geoPath(Point) does not treat the point as part of a line",
      () {
    final path = GeoPath()..transform = equirectangular;
    expect(
        normalizePath(path({
          "type": "LineString",
          "coordinates": [
            [-63, 18],
            [-62, 18],
            [-62, 17]
          ]
        }) as String),
        equals("M165,160L170,160L170,165"));
    expect(
        normalizePath(path({
          "type": "Point",
          "coordinates": [-63, 18]
        }) as String),
        equals(
            "M165,160m0,4.500000a4.500000,4.500000 0 1,1 0,-9a4.500000,4.500000 0 1,1 0,9z"));
  });
}

final reNumber = RegExp(r'[-+]?(?:\d+\.\d+|\d+\.|\.\d+|\d+)(?:[eE][-]?\d+)?');

String? normalizePath(String? path) =>
    path?.replaceAllMapped(reNumber, formatNumber);

String formatNumber(Match m) {
  var n = num.parse(m[0]!);
  return (n - n.round()).abs() < 1e-6
      ? n.round().toString()
      : n.toStringAsFixed(6);
}
