import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test("identity(point) returns the point", () {
    final identity = GeoIdentity()
          ..translate = [0, 0]
          ..scale = 1,
        projectionEqual = ProjectionEqual(identity);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [-180, 0],
      [-180, 0]
    ], projectionEqual);
    expect([
      [180, 0],
      [180, 0]
    ], projectionEqual);
    expect([
      [30, 30],
      [30, 30]
    ], projectionEqual);
  });

  test("identity(point).scale(…).translate(…) returns the transformed point",
      () {
    final identity = GeoIdentity()
          ..translate = [100, 10]
          ..scale = 2,
        projectionEqual = ProjectionEqual(identity);
    expect([
      [0, 0],
      [100, 10]
    ], projectionEqual);
    expect([
      [-180, 0],
      [-260, 10]
    ], projectionEqual);
    expect([
      [180, 0],
      [460, 10]
    ], projectionEqual);
    expect([
      [30, 30],
      [160, 70]
    ], projectionEqual);
  });

  test(
      "identity(point).reflectX(…) and reflectY() return the transformed point",
      () {
    final identity = GeoIdentity()
          ..translate = [100, 10]
          ..scale = 2
          ..reflectX = false
          ..reflectY = false,
        projectionEqual = ProjectionEqual(identity);
    expect([
      [3, 7],
      [106, 24]
    ], projectionEqual);
    expect(
      [
        [3, 7],
        [94, 24]
      ],
      projectionEqual..projection = (identity..reflectX = true),
    );
    expect([
      [3, 7],
      [94, -4]
    ], projectionEqual..projection = (identity..reflectY = true));
    expect([
      [3, 7],
      [106, -4]
    ], projectionEqual..projection = (identity..reflectX = false));
    expect([
      [3, 7],
      [106, 24]
    ], projectionEqual..projection = (identity..reflectY = false));
  });

  test("geoPath(identity) returns the path", () {
    final identity = GeoIdentity()
          ..translate = [0, 0]
          ..scale = 1,
        path = GeoPath()..transform = identity;
    expect(
        normalizePath(path({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [10, 10]
          ]
        }) as String),
        "M0,0L10,10");
    identity
      ..translate = [30, 90]
      ..scale = 2
      ..reflectY = true;
    expect(
        normalizePath(path({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [10, 10]
          ]
        }) as String),
        "M30,90L50,70");
  });

  test("geoPath(identity) respects clipExtent", () {
    final identity = GeoIdentity()
          ..translate = [0, 0]
          ..scale = 1,
        path = GeoPath()..transform = identity;
    identity.clipExtent = [
      [5, 5],
      [40, 80]
    ];
    expect(
        normalizePath(path({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [10, 10]
          ]
        }) as String),
        "M5,5L10,10");
    identity
      ..translate = [30, 90]
      ..scale = 2
      ..reflectY = true
      ..clipExtent = [
        [35, 76],
        [45, 86]
      ];
    expect(
        normalizePath(path({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [10, 10]
          ]
        }) as String),
        "M35,85L44,76");
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
