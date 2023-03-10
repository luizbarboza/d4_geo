// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:d4_geo/src/extent.dart';
import 'package:test/test.dart';

void main() {
  test("graticule.extent(…) sets extentMinor and extentMajor", () {
    final g = GeoGraticule()
      ..extent = [
        [-90, -45],
        [90, 45]
      ];
    expect(
        g.extentMinor,
        equals([
          [-90, -45],
          [90, 45]
        ]));
    expect(
        g.extentMajor,
        equals([
          [-90, -45],
          [90, 45]
        ]));
  });

  test("graticule.extent() gets extentMinor", () {
    final g = GeoGraticule()
      ..extentMinor = [
        [-90, -45],
        [90, 45]
      ];
    expect(
        g.extent,
        equals([
          [-90, -45],
          [90, 45]
        ]));
  });

  test(
      "graticule.extentMajor() default longitude ranges from 180°W (inclusive) to 180°E (exclusive)",
      () {
    final e = GeoGraticule().extentMajor;
    expect(e[0][0], equals(-180));
    expect(e[1][0], equals(180));
  });

  test(
      "graticule.extentMajor() default latitude ranges from 90°S (exclusive) to 90°N (exclusive)",
      () {
    final e = GeoGraticule().extentMajor;
    expect(e[0][1], equals(-90 + 1e-6));
    expect(e[1][1], equals(90 - 1e-6));
  });

  /*
  test("graticule.extentMajor(…) coerces input values to numbers", () {
    final g = GeoGraticule()..extentMajor = [["-90", "-45"], ["+90", "+45"]];
    final e = g.extentMajor;
    expect(e[0][0], -90);
    expect(e[0][1], -45);
    expect(e[1][0], 90);
    expect(e[1][1], 45);
  });
  */

  test(
      "graticule.extentMinor() default longitude ranges from 180°W (inclusive) to 180°E (exclusive)",
      () {
    final e = GeoGraticule().extentMinor;
    expect(e[0][0], equals(-180));
    expect(e[1][0], equals(180));
  });

  test(
      "graticule.extentMinor() default latitude ranges from 80°S (inclusive) to 80°N (inclusive)",
      () {
    final e = GeoGraticule().extentMinor;
    expect(e[0][1], equals(-80 - 1e-6));
    expect(e[1][1], equals(80 + 1e-6));
  });

  /*
  test("graticule.extentMinor(…) coerces input values to numbers", () {
    final g = GeoGraticule()..extentMinor = [["-90", "-45"], ["+90", "+45"]];
    final e = g.extentMinor;
    expect(e[0][0], -90);
    expect(e[0][1], -45);
    expect(e[1][0], 90);
    expect(e[1][1], 45);
  });
  */

  test("graticule.step(…) sets the minor and major step", () {
    final g = GeoGraticule()..step = [22.5, 22.5];
    expect(g.stepMinor, equals([22.5, 22.5]));
    expect(g.stepMajor, equals([22.5, 22.5]));
  });

  test("graticule.step() gets the minor step", () {
    final g = GeoGraticule()..stepMinor = [22.5, 22.5];
    expect(g.step, equals([22.5, 22.5]));
  });

  test("graticule.stepMinor() defaults to 10°, 10°", () {
    expect(GeoGraticule().stepMinor, equals([10, 10]));
  });

  /*
  test("graticule.stepMinor(…) coerces input values to numbers", () {
    final g = GeoGraticule()..stepMinor = ["45", "11.25"];
    final s = g.stepMinor;
    expect(s[0], 45);
    expect(s[1], 11.25);
  });
  */

  test("graticule.stepMajor() defaults to 90°, 360°", () {
    expect(GeoGraticule().stepMajor, equals([90, 360]));
  });

  /*
  test("graticule.stepMajor(…) coerces input values to numbers", () {
    final g = GeoGraticule()..stepMajor = ["45", "11.25"];
    final s = g.stepMajor;
    expect(s[0], 45);
    expect(s[1], 11.25);
  });
  */

  test(
      "graticule.lines() default longitude ranges from 180°W (inclusive) to 180°E (exclusive)",
      () {
    final lines = GeoGraticule()
        .lines
        .where((line) => line["coordinates"][0][0] == line["coordinates"][1][0])
        .toList()
      ..sort(
          (a, b) => a["coordinates"][0][0].compareTo(b["coordinates"][0][0]));
    expect(lines[0]["coordinates"][0][0], -180);
    expect(lines[lines.length - 1]["coordinates"][0][0], equals(170));
  });

  test(
      "graticule.lines() default latitude ranges from 90°S (exclusive) to 90°N (exclusive)",
      () {
    final lines = GeoGraticule()
        .lines
        .where((line) => line["coordinates"][0][1] == line["coordinates"][1][1])
        .toList()
      ..sort(
          (a, b) => a["coordinates"][0][1].compareTo(b["coordinates"][0][1]));
    expect(lines[0]["coordinates"][0][1], -80);
    expect(lines[lines.length - 1]["coordinates"][0][1], equals(80));
  });

  test(
      "graticule.lines() default minor longitude lines extend from 80°S to 80°N",
      () {
    final lines = GeoGraticule()
        .lines
        .where((line) => line["coordinates"][0][0] == line["coordinates"][1][0])
        .where((line) => (line["coordinates"][0][0] % 90).abs() > 1e-6);
    for (final line in lines) {
      expect(
          extentBy<List<double>, double>(
              line["coordinates"], (p, _, __) => p?[1]),
          equals([-80 - 1e-6, 80 + 1e-6]));
    }
  });

  test(
      "graticule.lines() default major longitude lines extend from 90°S to 90°N",
      () {
    final lines = GeoGraticule()
        .lines
        .where((line) => line["coordinates"][0][0] == line["coordinates"][1][0])
        .where((line) => (line["coordinates"][0][0] % 90).abs() < 1e-6);
    for (final line in lines) {
      expect(
          extentBy<List<double>, double>(
              line["coordinates"], (p, _, __) => p?[1]),
          equals([-90 + 1e-6, 90 - 1e-6]));
    }
  });

  test("graticule.lines() default latitude lines extend from 180°W to 180°E",
      () {
    final lines = GeoGraticule().lines.where(
        (line) => line["coordinates"][0][1] == line["coordinates"][1][1]);
    for (final line in lines) {
      expect(
          extentBy<List<double>, double>(
              line["coordinates"], (p, _, __) => p?[0]),
          equals([-180, 180]));
    }
  });

  test("graticule.lines() returns an array of LineStrings", () {
    expect(
        (GeoGraticule()
              ..extent = [
                [-90, -45],
                [90, 45]
              ]
              ..step = [45, 45]
              ..precision = 3)
            .lines,
        equals([
          {
            "type": "LineString",
            "coordinates": [
              [-90, -45],
              [-90, 45]
            ]
          }, // meridian
          {
            "type": "LineString",
            "coordinates": [
              [-45, -45],
              [-45, 45]
            ]
          }, // meridian
          {
            "type": "LineString",
            "coordinates": [
              [0, -45],
              [0, 45]
            ]
          }, // meridian
          {
            "type": "LineString",
            "coordinates": [
              [45, -45],
              [45, 45]
            ]
          }, // meridian
          {
            "type": "LineString",
            "coordinates": [
              [-90, -45],
              [-87, -45],
              [-84, -45],
              [-81, -45],
              [-78, -45],
              [-75, -45],
              [-72, -45],
              [-69, -45],
              [-66, -45],
              [-63, -45],
              [-60, -45],
              [-57, -45],
              [-54, -45],
              [-51, -45],
              [-48, -45],
              [-45, -45],
              [-42, -45],
              [-39, -45],
              [-36, -45],
              [-33, -45],
              [-30, -45],
              [-27, -45],
              [-24, -45],
              [-21, -45],
              [-18, -45],
              [-15, -45],
              [-12, -45],
              [-9, -45],
              [-6, -45],
              [-3, -45],
              [0, -45],
              [3, -45],
              [6, -45],
              [9, -45],
              [12, -45],
              [15, -45],
              [18, -45],
              [21, -45],
              [24, -45],
              [27, -45],
              [30, -45],
              [33, -45],
              [36, -45],
              [39, -45],
              [42, -45],
              [45, -45],
              [48, -45],
              [51, -45],
              [54, -45],
              [57, -45],
              [60, -45],
              [63, -45],
              [66, -45],
              [69, -45],
              [72, -45],
              [75, -45],
              [78, -45],
              [81, -45],
              [84, -45],
              [87, -45],
              [90, -45]
            ]
          },
          {
            "type": "LineString",
            "coordinates": [
              [-90, 0],
              [-87, 0],
              [-84, 0],
              [-81, 0],
              [-78, 0],
              [-75, 0],
              [-72, 0],
              [-69, 0],
              [-66, 0],
              [-63, 0],
              [-60, 0],
              [-57, 0],
              [-54, 0],
              [-51, 0],
              [-48, 0],
              [-45, 0],
              [-42, 0],
              [-39, 0],
              [-36, 0],
              [-33, 0],
              [-30, 0],
              [-27, 0],
              [-24, 0],
              [-21, 0],
              [-18, 0],
              [-15, 0],
              [-12, 0],
              [-9, 0],
              [-6, 0],
              [-3, 0],
              [0, 0],
              [3, 0],
              [6, 0],
              [9, 0],
              [12, 0],
              [15, 0],
              [18, 0],
              [21, 0],
              [24, 0],
              [27, 0],
              [30, 0],
              [33, 0],
              [36, 0],
              [39, 0],
              [42, 0],
              [45, 0],
              [48, 0],
              [51, 0],
              [54, 0],
              [57, 0],
              [60, 0],
              [63, 0],
              [66, 0],
              [69, 0],
              [72, 0],
              [75, 0],
              [78, 0],
              [81, 0],
              [84, 0],
              [87, 0],
              [90, 0]
            ]
          }
        ]));
  });

  test("graticule() returns a MultiLineString of all lines", () {
    final g = GeoGraticule()
      ..extent = [
        [-90, -45],
        [90, 45]
      ]
      ..step = [45, 45]
      ..precision = 3;
    expect(g(), {
      "type": "MultiLineString",
      "coordinates": g.lines.map((line) => line["coordinates"])
    });
  });

  test("graticule.outline() returns a Polygon encompassing the major extent",
      () {
    expect(
        (GeoGraticule()
              ..extentMajor = [
                [-90, -45],
                [90, 45]
              ]
              ..precision = 3)
            .outline,
        {
          "type": "Polygon",
          "coordinates": [
            [
              [-90, -45], [-90, 45], // meridian
              [-87, 45],
              [-84, 45],
              [-81, 45],
              [-78, 45],
              [-75, 45],
              [-72, 45],
              [-69, 45],
              [-66, 45],
              [-63, 45],
              [-60, 45],
              [-57, 45],
              [-54, 45],
              [-51, 45],
              [-48, 45],
              [-45, 45],
              [-42, 45],
              [-39, 45],
              [-36, 45],
              [-33, 45],
              [-30, 45],
              [-27, 45],
              [-24, 45],
              [-21, 45],
              [-18, 45],
              [-15, 45],
              [-12, 45],
              [-9, 45],
              [-6, 45],
              [-3, 45],
              [0, 45],
              [3, 45],
              [6, 45],
              [9, 45],
              [12, 45],
              [15, 45],
              [18, 45],
              [21, 45],
              [24, 45],
              [27, 45],
              [30, 45],
              [33, 45],
              [36, 45],
              [39, 45],
              [42, 45],
              [45, 45],
              [48, 45],
              [51, 45],
              [54, 45],
              [57, 45],
              [60, 45],
              [63, 45],
              [66, 45],
              [69, 45],
              [72, 45],
              [75, 45],
              [78, 45],
              [81, 45],
              [84, 45],
              [87, 45],
              [90, 45], [90, -45], // meridian
              [87, -45],
              [84, -45],
              [81, -45],
              [78, -45],
              [75, -45],
              [72, -45],
              [69, -45],
              [66, -45],
              [63, -45],
              [60, -45],
              [57, -45],
              [54, -45],
              [51, -45],
              [48, -45],
              [45, -45],
              [42, -45],
              [39, -45],
              [36, -45],
              [33, -45],
              [30, -45],
              [27, -45],
              [24, -45],
              [21, -45],
              [18, -45],
              [15, -45],
              [12, -45],
              [9, -45],
              [6, -45],
              [3, -45],
              [0, -45],
              [-3, -45],
              [-6, -45],
              [-9, -45],
              [-12, -45],
              [-15, -45],
              [-18, -45],
              [-21, -45],
              [-24, -45],
              [-27, -45],
              [-30, -45],
              [-33, -45],
              [-36, -45],
              [-39, -45],
              [-42, -45],
              [-45, -45],
              [-48, -45],
              [-51, -45],
              [-54, -45],
              [-57, -45],
              [-60, -45],
              [-63, -45],
              [-66, -45],
              [-69, -45],
              [-72, -45],
              [-75, -45],
              [-78, -45],
              [-81, -45],
              [-84, -45],
              [-87, -45],
              [-90, -45]
            ]
          ]
        });
  });
}
