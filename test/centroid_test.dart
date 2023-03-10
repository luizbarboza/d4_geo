// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';

import 'package:d4_geo/d4_geo.dart';
import 'package:d4_geo/src/range.dart';
import 'package:test/test.dart';

void main() {
  test("the centroid of a point is itself", () {
    expect(
        geoCentroid({
          "type": "Point",
          "coordinates": [0, 0]
        }),
        equals([0, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Point",
          "coordinates": [1, 1]
        }),
        equals([1, 1].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Point",
          "coordinates": [2, 3]
        }),
        equals([2, 3].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Point",
          "coordinates": [-4, -5]
        }),
        equals([-4, -5].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a set of points is the (spherical) average of its constituent members",
      () {
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {
              "type": "Point",
              "coordinates": [1, 2]
            }
          ]
        }),
        equals([0.499847, 1.000038].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }),
        equals([0.499847, 1.000038].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "MultiPoint",
          "coordinates": [
            [179, 0],
            [-179, 0]
          ]
        }),
        equals([180, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a set of points and their antipodes is ambiguous", () {
    expect(
        geoCentroid({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [180, 0]
          ]
        }),
        everyElement(isNaN));
    expect(
        geoCentroid({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [90, 0],
            [180, 0],
            [-90, 0]
          ]
        }),
        everyElement(isNaN));
    expect(
        geoCentroid({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [0, 90],
            [180, 0],
            [0, -90]
          ]
        }),
        everyElement(isNaN));
  });

  test("the centroid of the empty set of points is ambiguous", () {
    expect(geoCentroid({"type": "MultiPoint", "coordinates": []}),
        everyElement(isNaN));
  });

  test(
      "the centroid of a line string is the (spherical) average of its constituent great arc segments",
      () {
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 0]
          ]
        }),
        equals([0.5, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [0, 90]
          ]
        }),
        equals([0, 45].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [0, 45],
            [0, 90]
          ]
        }),
        equals([0, 45].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [-1, -1],
            [1, 1]
          ]
        }),
        equals([0, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [-60, -1],
            [60, 1]
          ]
        }),
        equals([0, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [179, -1],
            [-179, 1]
          ]
        }),
        equals([180, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [-179, 0],
            [0, 0],
            [179, 0]
          ]
        }),
        equals([0, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [-180, -90],
            [0, 0],
            [0, 90]
          ]
        }),
        equals([0, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a great arc from a point to its antipode is ambiguous",
      () {
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [180, 0],
            [0, 0]
          ]
        }),
        everyElement(isNaN));
    expect(
        geoCentroid({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, -90],
              [0, 90]
            ]
          ]
        }),
        everyElement(isNaN));
  });

  test(
      "the centroid of a set of line strings is the (spherical) average of its constituent great arc segments",
      () {
    expect(
        geoCentroid({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, 0],
              [0, 2]
            ]
          ]
        }),
        equals([0, 1].map((a) => closeTo(a, 1e-6))));
  });

  test("a line of zero length is treated as points", () {
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [1, 1],
            [1, 1]
          ]
        }),
        equals([1, 1].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {
              "type": "LineString",
              "coordinates": [
                [1, 2],
                [1, 2]
              ]
            }
          ]
        }),
        equals([0.666534, 1.333408].map((a) => closeTo(a, 1e-6))));
  });

  test("an empty polygon with non-zero extent is treated as a line", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [1, 1],
              [2, 1],
              [3, 1],
              [2, 1],
              [1, 1]
            ]
          ]
        }),
        equals([2, 1.000076].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {
              "type": "Polygon",
              "coordinates": [
                [
                  [1, 2],
                  [1, 2],
                  [1, 2],
                  [1, 2]
                ]
              ]
            }
          ]
        }),
        equals([0.799907, 1.600077].map((a) => closeTo(a, 1e-6))));
  });

  test("an empty polygon with zero extent is treated as a point", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [1, 1],
              [1, 1],
              [1, 1],
              [1, 1]
            ]
          ]
        }),
        equals([1, 1].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {
              "type": "Polygon",
              "coordinates": [
                [
                  [1, 2],
                  [1, 2],
                  [1, 2],
                  [1, 2]
                ]
              ]
            }
          ]
        }),
        equals([0.799907, 1.600077].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of the equator is ambiguous", () {
    expect(
        geoCentroid({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [120, 0],
            [-120, 0],
            [0, 0]
          ]
        }),
        everyElement(isNaN));
  });

  test("the centroid of a polygon is the (spherical) average of its surface",
      () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -90],
              [0, 0],
              [0, 90],
              [1, 0],
              [0, -90]
            ]
          ]
        }),
        equals([0.5, 0].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            range(start: -180, stop: 180 + 1 / 2).map((x) => [x, -60]).toList()
          ]
        })[1],
        closeTo(-90, 1e-6));
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -10],
              [0, 10],
              [10, 10],
              [10, -10],
              [0, -10]
            ]
          ]
        }),
        equals([5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a set of polygons is the (spherical) average of its surface",
      () {
    final circle = GeoCircle();
    expect(
        geoCentroid({
          "type": "MultiPolygon",
          "coordinates": [
            (circle
              ..radius = 45
              ..center = [90, 0])()["coordinates"],
            (circle
              ..radius = 60
              ..center = [-90, 0])()["coordinates"]
          ]
        }),
        equals([-90, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a lune is the (spherical) average of its surface", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -90],
              [0, 0],
              [0, 90],
              [1, 0],
              [0, -90]
            ]
          ]
        }),
        equals([0.5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a small circle is its center: 5°", () {
    expect(
        geoCentroid((GeoCircle()
          ..radius = 5
          ..center = [30, 45])()),
        equals([30, 45].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a small circle is its center: 135°", () {
    expect(
        geoCentroid((GeoCircle()
          ..radius = 135
          ..center = [30, 45])()),
        equals([30, 45].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a small circle is its center: South Pole", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            range(start: -180, stop: 180 + 1 / 2).map((x) => [x, -60]).toList()
          ]
        })[1],
        equals(-90));
  });

  test("the centroid of a small circle is its center: equator", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -10],
              [0, 10],
              [10, 10],
              [10, -10],
              [0, -10]
            ]
          ]
        }),
        equals([5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a small circle is its center: equator with coincident points",
      () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -10],
              [0, 10],
              [0, 10],
              [10, 10],
              [10, -10],
              [0, -10]
            ]
          ]
        }),
        equals([5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a small circle is its center: other", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [-180, 0],
              [-180, 10],
              [-179, 10],
              [-179, 0],
              [-180, 0]
            ]
          ]
        }),
        equals([-179.5, 4.987448].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a small circle is its center: concentric rings", () {
    final circle = GeoCircle()..center = [0, 45],
        coordinates =
            ((circle..radius = 60)()["coordinates"] as List<List<List<num>>>);
    coordinates.add(
        ((circle..radius = 45)()["coordinates"][0] as List<List<num>>)
            .reversed
            .toList());
    expect(geoCentroid({"type": "Polygon", "coordinates": coordinates}),
        equals([0, 45].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a spherical square on the equator", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [0, -10],
              [0, 10],
              [10, 10],
              [10, -10],
              [0, -10]
            ]
          ]
        }),
        equals([5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a spherical square touching the antimeridian", () {
    expect(
        geoCentroid({
          "type": "Polygon",
          "coordinates": [
            [
              [-180, 0],
              [-180, 10],
              [-179, 10],
              [-179, 0],
              [-180, 0]
            ]
          ]
        }),
        equals([-179.5, 4.987448].map((a) => closeTo(a, 1e-6))));
  });

  test("concentric rings", () {
    final circle = GeoCircle()..center = [0, 45],
        coordinates =
            (circle..radius = 60)()["coordinates"] as List<List<List<num>>>;
    coordinates.add(
        ((circle..radius = 45)()["coordinates"][0] as List<List<num>>)
            .reversed
            .toList());
    expect(geoCentroid({"type": "Polygon", "coordinates": coordinates}),
        equals([0, 45].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of a sphere is ambiguous", () {
    expect(geoCentroid({"type": "Sphere"}), everyElement(isNaN));
  });

  test("the centroid of a feature is the centroid of its constituent geometry",
      () {
    expect(
        geoCentroid({
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": [
              [1, 1],
              [1, 1]
            ]
          }
        }),
        equals([1, 1].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [1, 1]
          }
        }),
        equals([1, 1].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [0, -90],
                [0, 0],
                [0, 90],
                [1, 0],
                [0, -90]
              ]
            ]
          }
        }),
        equals([0.5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a feature collection is the centroid of its constituent geometry",
      () {
    expect(
        geoCentroid({
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
        equals([179.5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a non-empty line string and a point only considers the line string",
      () {
    expect(
        geoCentroid({
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
        equals([179.5, 0].map((a) => closeTo(a, 1e-6))));
  });

  test(
      "the centroid of a non-empty polygon, a non-empty line string and a point only considers the polygon",
      () {
    expect(
        geoCentroid({
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
        equals([-179.5, 0.500006].map((a) => closeTo(a, 1e-6))));
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {
              "type": "LineString",
              "coordinates": [
                [179, 0],
                [180, 0]
              ]
            },
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
            }
          ]
        }),
        equals([-179.5, 0.500006].map((a) => closeTo(a, 1e-6))));
  });

  test("the centroid of the sphere and a point is the point", () {
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {"type": "Sphere"},
            {
              "type": "Point",
              "coordinates": [0, 0]
            }
          ]
        }),
        equals([0, 0]));
    expect(
        geoCentroid({
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            },
            {"type": "Sphere"}
          ]
        }),
        equals([0, 0]));
  });

  test("the centroid of a detailed feature is correct", () {
    final ny = jsonDecode(File("./test/data/ny.json").readAsStringSync());
    expect(geoCentroid(ny),
        equals([-73.93079, 40.69447].map((a) => closeTo(a, 1e-5))));
  });
}
