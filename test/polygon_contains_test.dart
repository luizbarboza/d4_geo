// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:d4_geo/src/polygon_contains.dart' as geo;
import 'package:test/test.dart';

bool polygonContains(List<List<List<num>>> polygon, List<num> point) =>
    geo.polygonContains(polygon.map(ringRadians).toList(), pointRadians(point));

void main() {
  test("geoPolygonContains(empty, point) returns false", () {
    expect(polygonContains([], [0, 0]), equals(false));
  });

  test("geoPolygonContains(simple, point) returns the expected value", () {
    final polygon = [
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 0],
        [0, 0]
      ]
    ];
    expect(polygonContains(polygon, [0.1, 2]), equals(false));
    expect(polygonContains(polygon, [0.1, 0.1]), equals(true));
  });

  test("geoPolygonContains(smallCircle, point) returns the expected value", () {
    final polygon = GeoCircle(radius: 60)()["coordinates"];
    expect(polygonContains(polygon, [-180, 0]), equals(false));
    expect(polygonContains(polygon, [1, 1]), equals(true));
  });

  test("geoPolygonContains wraps longitudes", () {
    final polygon = GeoCircle(center: [300, 0])()["coordinates"];
    expect(polygonContains(polygon, [300, 0]), equals(true));
    expect(polygonContains(polygon, [-60, 0]), equals(true));
    expect(polygonContains(polygon, [-420, 0]), equals(true));
  });

  test("geoPolygonContains(southPole, point) returns the expected value", () {
    final polygon = [
      [
        [-60, -80],
        [60, -80],
        [180, -80],
        [-60, -80]
      ]
    ];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, -85]), equals(true));
    expect(polygonContains(polygon, [0, -90]), equals(true));
  });

  test("geoPolygonContains(northPole, point) returns the expected value", () {
    final polygon = [
      [
        [60, 80],
        [-60, 80],
        [-180, 80],
        [60, 80]
      ]
    ];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, 85]), equals(true));
    expect(polygonContains(polygon, [0, 90]), equals(true));
    expect(polygonContains(polygon, [-100, 90]), equals(true));
    expect(polygonContains(polygon, [0, -90]), equals(false));
  });

  test("geoPolygonContains(touchingPole, Pole) returns true (issue #105)", () {
    final polygon = [
      [
        [0, -30],
        [120, -30],
        [0, -90],
        [0, -30]
      ]
    ];
    expect(polygonContains(polygon, [0, -90]), equals(false));
    expect(polygonContains(polygon, [-60, -90]), equals(false));
    expect(polygonContains(polygon, [60, -90]), equals(false));
    final polygon2 = [
      [
        [0, 30],
        [-120, 30],
        [0, 90],
        [0, 30]
      ]
    ];
    expect(polygonContains(polygon2, [0, 90]), equals(false));
    expect(polygonContains(polygon2, [-60, 90]), equals(false));
    expect(polygonContains(polygon2, [60, 90]), equals(false));
  });

  test("geoPolygonContains(southHemispherePoly) returns the expected value",
      () {
    final polygon = [
      [
        [0, 0],
        [10, -40],
        [-10, -40],
        [0, 0]
      ]
    ];
    expect(polygonContains(polygon, [0, -40.2]), equals(true));
    expect(polygonContains(polygon, [0, -40.5]), equals(false));
  });

  test("geoPolygonContains(largeNearOrigin, point) returns the expected value",
      () {
    final polygon = [
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [0, 1],
        [0, 0]
      ]
    ];
    expect(polygonContains(polygon, [0.1, 0.1]), equals(false));
    expect(polygonContains(polygon, [2, 0.1]), equals(true));
  });

  test(
      "geoPolygonContains(largeNearSouthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [-60, 80],
        [60, 80],
        [180, 80],
        [-60, 80]
      ]
    ];
    expect(polygonContains(polygon, [0, 85]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test(
      "geoPolygonContains(largeNearNorthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [60, -80],
        [-60, -80],
        [-180, -80],
        [60, -80]
      ]
    ];
    expect(polygonContains(polygon, [0, -85]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test("geoPolygonContains(largeCircle, point) returns the expected value", () {
    final polygon = GeoCircle(radius: 120)()["coordinates"];
    expect(polygonContains(polygon, [-180, 0]), equals(false));
    expect(polygonContains(polygon, [-90, 0]), equals(true));
  });

  test(
      "geoPolygonContains(largeNarrowStripHole, point) returns the expected value",
      () {
    final polygon = [
      [
        [-170, -1],
        [0, -1],
        [170, -1],
        [170, 1],
        [0, 1],
        [-170, 1],
        [-170, -1]
      ]
    ];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, 20]), equals(true));
  });

  test(
      "geoPolygonContains(largeNarrowEquatorialHole, point) returns the expected value",
      () {
    final circle = GeoCircle(center: [0, -90]),
        ring0 = ((circle..radius = 90 - 0.01)()["coordinates"][0]
            as List<List<num>>),
        ring1 = ((circle..radius = 90 + 0.01)()["coordinates"][0]
                as List<List<num>>)
            .reversed
            .toList();
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, -90]), equals(true));
  });

  test(
      "geoPolygonContains(largeNarrowEquatorialStrip, point) returns the expected value",
      () {
    final circle = GeoCircle(center: [0, -90]),
        ring0 = ((circle..radius = 90 + 0.01)()["coordinates"][0]
            as List<List<num>>),
        ring1 = ((circle..radius = 90 - 0.01)()["coordinates"][0]
                as List<List<num>>)
            .reversed
            .toList();
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, -90]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test("geoPolygonContains(ringNearOrigin, point) returns the expected value",
      () {
    final ring0 = [
          [0, 0],
          [0, 1],
          [1, 1],
          [1, 0],
          [0, 0]
        ],
        ring1 = [
          [0.4, 0.4],
          [0.6, 0.4],
          [0.6, 0.6],
          [0.4, 0.6],
          [0.4, 0.4]
        ];
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0.5, 0.5]), equals(false));
    expect(polygonContains(polygon, [0.1, 0.5]), equals(true));
  });

  test("geoPolygonContains(ringEquatorial, point) returns the expected value",
      () {
    final ring0 = [
          [0, -10],
          [-120, -10],
          [120, -10],
          [0, -10]
        ],
        ring1 = [
          [0, 10],
          [120, 10],
          [-120, 10],
          [0, 10]
        ];
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, 20]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test(
      "geoPolygonContains(ringExcludingBothPoles, point) returns the expected value",
      () {
    final ring0 = [
          [10, 10],
          [-10, 10],
          [-10, -10],
          [10, -10],
          [10, 10]
        ].reversed.toList(),
        ring1 = [
          [170, 10],
          [170, -10],
          [-170, -10],
          [-170, 10],
          [170, 10]
        ].reversed.toList();
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, 90]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test(
      "geoPolygonContains(ringContainingBothPoles, point) returns the expected value",
      () {
    final ring0 = [
          [10, 10],
          [-10, 10],
          [-10, -10],
          [10, -10],
          [10, 10]
        ],
        ring1 = [
          [170, 10],
          [170, -10],
          [-170, -10],
          [-170, 10],
          [170, 10]
        ];
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, 20]), equals(true));
  });

  test(
      "geoPolygonContains(ringContainingSouthPole, point) returns the expected value",
      () {
    final ring0 = [
          [10, 10],
          [-10, 10],
          [-10, -10],
          [10, -10],
          [10, 10]
        ],
        ring1 = [
          [0, 80],
          [120, 80],
          [-120, 80],
          [0, 80]
        ];
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, 90]), equals(false));
    expect(polygonContains(polygon, [0, -90]), equals(true));
  });

  test(
      "geoPolygonContains(ringContainingNorthPole, point) returns the expected value",
      () {
    final ring0 = [
          [10, 10],
          [-10, 10],
          [-10, -10],
          [10, -10],
          [10, 10]
        ].reversed.toList(),
        ring1 = [
          [0, 80],
          [120, 80],
          [-120, 80],
          [0, 80]
        ].reversed.toList();
    final polygon = [ring0, ring1];
    expect(polygonContains(polygon, [0, -90]), equals(false));
    expect(polygonContains(polygon, [0, 90]), equals(true));
  });

  test(
      "geoPolygonContains(selfIntersectingNearOrigin, point) returns the expected value",
      () {
    final polygon = [
      [
        [0, 0],
        [1, 0],
        [1, 3],
        [3, 3],
        [3, 1],
        [0, 1],
        [0, 0]
      ]
    ];
    expect(polygonContains(polygon, [15, 0.5]), equals(false));
    expect(polygonContains(polygon, [12, 2]), equals(false));
    expect(polygonContains(polygon, [0.5, 0.5]), equals(true));
    expect(polygonContains(polygon, [2, 2]), equals(true));
  });

  test(
      "geoPolygonContains(selfIntersectingNearSouthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [-10, -80],
        [120, -80],
        [-120, -80],
        [10, -85],
        [10, -75],
        [-10, -75],
        [-10, -80]
      ]
    ];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, -76]), equals(true));
    expect(polygonContains(polygon, [0, -89]), equals(true));
  });

  test(
      "geoPolygonContains(selfIntersectingNearNorthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [-10, 80],
        [-10, 75],
        [10, 75],
        [10, 85],
        [-120, 80],
        [120, 80],
        [-10, 80]
      ]
    ];
    expect(polygonContains(polygon, [0, 0]), equals(false));
    expect(polygonContains(polygon, [0, 76]), equals(true));
    expect(polygonContains(polygon, [0, 89]), equals(true));
  });

  test(
      "geoPolygonContains(hemisphereTouchingTheSouthPole, point) returns the expected value",
      () {
    final polygon = GeoCircle()()["coordinates"];
    expect(polygonContains(polygon, [0, 0]), equals(true));
  });

  test(
      "geoPolygonContains(triangleTouchingTheSouthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [180, -90],
        [-45, 0],
        [45, 0],
        [180, -90]
      ]
    ];
    expect(polygonContains(polygon, [-46, 0]), equals(false));
    expect(polygonContains(polygon, [0, 1]), equals(false));
    expect(polygonContains(polygon, [-90, -80]), equals(false));
    expect(polygonContains(polygon, [-44, 0]), equals(true));
    expect(polygonContains(polygon, [0, 0]), equals(true));
    expect(polygonContains(polygon, [0, -30]), equals(true));
    expect(polygonContains(polygon, [30, -80]), equals(true));
  });

  test(
      "geoPolygonContains(triangleTouchingTheSouthPole2, point) returns the expected value",
      () {
    final polygon = [
      [
        [-45, 0],
        [45, 0],
        [180, -90],
        [-45, 0]
      ]
    ];
    expect(polygonContains(polygon, [-46, 0]), equals(false));
    expect(polygonContains(polygon, [0, 1]), equals(false));
    expect(polygonContains(polygon, [-90, -80]), equals(false));
    expect(polygonContains(polygon, [-44, 0]), equals(true));
    expect(polygonContains(polygon, [0, 0]), equals(true));
    expect(polygonContains(polygon, [0, -30]), equals(true));
    expect(polygonContains(polygon, [30, -80]), equals(true));
  });

  test(
      "geoPolygonContains(triangleTouchingTheSouthPole3, point) returns the expected value",
      () {
    final polygon = [
      [
        [180, -90],
        [-135, 0],
        [135, 0],
        [180, -90]
      ]
    ];
    expect(polygonContains(polygon, [180, 0]), equals(false));
    expect(polygonContains(polygon, [150, 0]), equals(false));
    expect(polygonContains(polygon, [180, -30]), equals(false));
    expect(polygonContains(polygon, [150, -80]), equals(false));
    expect(polygonContains(polygon, [0, 0]), equals(true));
    expect(polygonContains(polygon, [180, 1]), equals(true));
    expect(polygonContains(polygon, [-90, -80]), equals(true));
  });

  test(
      "geoPolygonContains(triangleTouchingTheNorthPole, point) returns the expected value",
      () {
    final polygon = [
      [
        [180, 90],
        [45, 0],
        [-45, 0],
        [180, 90]
      ]
    ];
    expect(polygonContains(polygon, [-90, 0]), equals(false));
    expect(polygonContains(polygon, [0, -1]), equals(false));
    expect(polygonContains(polygon, [0, -80]), equals(false));
    expect(polygonContains(polygon, [-90, 1]), equals(false));
    expect(polygonContains(polygon, [-90, 80]), equals(false));
    expect(polygonContains(polygon, [-44, 10]), equals(true));
    expect(polygonContains(polygon, [0, 10]), equals(true));
    expect(polygonContains(polygon, [0, 10]), equals(true));
  });
}

List<List<num>> ringRadians(List<List<num>> ring) =>
    ring.map(pointRadians).toList()..removeLast();

List<num> pointRadians(List<num> point) =>
    [point[0] * pi / 180, point[1] * pi / 180];
