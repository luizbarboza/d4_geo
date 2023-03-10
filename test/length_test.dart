// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("geoLength(Point) returns zero", () {
    expect(
        geoLength({
          "type": "Point",
          "coordinates": [0, 0]
        }),
        closeTo(0, 1e-6));
  });

  test("geoLength(MultiPoint) returns zero", () {
    expect(
        geoLength({
          "type": "MultiPoint",
          "coordinates": [
            [0, 1],
            [2, 3]
          ]
        }),
        closeTo(0, 1e-6));
  });

  test("geoLength(LineString) returns the sum of its great-arc segments", () {
    expect(
        geoLength({
          "type": "LineString",
          "coordinates": [
            [-45, 0],
            [45, 0]
          ]
        }),
        closeTo(pi / 2, 1e-6));
    expect(
        geoLength({
          "type": "LineString",
          "coordinates": [
            [-45, 0],
            [-30, 0],
            [-15, 0],
            [0, 0]
          ]
        }),
        closeTo(pi / 4, 1e-6));
  });

  test("geoLength(MultiLineString) returns the sum of its great-arc segments",
      () {
    expect(
        geoLength({
          "type": "MultiLineString",
          "coordinates": [
            [
              [-45, 0],
              [-30, 0]
            ],
            [
              [-15, 0],
              [0, 0]
            ]
          ]
        }),
        closeTo(pi / 6, 1e-6));
  });

  test("geoLength(Polygon) returns the length of its perimeter", () {
    expect(
        geoLength({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [3, 0],
              [3, 3],
              [0, 3],
              [0, 0]
            ]
          ]
        }),
        closeTo(0.157008, 1e-6));
  });

  test(
      "geoLength(Polygon) returns the length of its perimeter, including holes",
      () {
    expect(
        geoLength({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [3, 0],
              [3, 3],
              [0, 3],
              [0, 0]
            ],
            [
              [1, 1],
              [2, 1],
              [2, 2],
              [1, 2],
              [1, 1]
            ]
          ]
        }),
        closeTo(0.209354, 1e-6));
  });

  test("geoLength(MultiPolygon) returns the summed length of the perimeters",
      () {
    expect(
        geoLength({
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [3, 0],
                [3, 3],
                [0, 3],
                [0, 0]
              ]
            ]
          ]
        }),
        closeTo(0.157008, 1e-6));
    expect(
        geoLength({
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [3, 0],
                [3, 3],
                [0, 3],
                [0, 0]
              ]
            ],
            [
              [
                [1, 1],
                [2, 1],
                [2, 2],
                [1, 2],
                [1, 1]
              ]
            ]
          ]
        }),
        closeTo(0.209354, 1e-6));
  });

  test("geoLength(FeatureCollection) returns the sum of its features’ lengths",
      () {
    expect(
        geoLength({
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [
                  [-45, 0],
                  [0, 0]
                ]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [
                  [0, 0],
                  [45, 0]
                ]
              }
            }
          ]
        }),
        closeTo(pi / 2, 1e-6));
  });

  test(
      "geoLength(GeometryCollection) returns the sum of its geometries’ lengths",
      () {
    expect(
        geoLength({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "GeometryCollection",
              "geometries": [
                {
                  "type": "LineString",
                  "coordinates": [
                    [-45, 0],
                    [0, 0]
                  ]
                }
              ]
            },
            {
              "type": "LineString",
              "coordinates": [
                [0, 0],
                [45, 0]
              ]
            }
          ]
        }),
        closeTo(pi / 2, 1e-6));
  });
}
