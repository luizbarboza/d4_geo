import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:d4_geo/src/range.dart';
import 'package:test/test.dart';

Map stripes(double a, double b) {
  var reverse = false;
  return {
    "type": "Polygon",
    "coordinates": [a, b].map((d) {
      final stripe =
          range(start: -180, stop: 180, step: 0.1).map((x) => [x, d]).toList();
      stripe.add(stripe[0]);
      if (!reverse) {
        reverse = true;
        return stripe;
      }
      return stripe.reversed.toList();
    }).toList()
  };
}

void main() {
  test("area: Point", () {
    expect(
        geoArea({
          "type": "Point",
          "coordinates": [0, 0]
        }),
        equals(0));
  });

  test("area: MultiPoint", () {
    expect(
        geoArea({
          "type": "MultiPoint",
          "coordinates": [
            [0, 1],
            [2, 3]
          ]
        }),
        equals(0));
  });

  test("area: LineString", () {
    expect(
        geoArea({
          "type": "LineString",
          "coordinates": [
            [0, 1],
            [2, 3]
          ]
        }),
        equals(0));
  });

  test("area: MultiLineString", () {
    expect(
        geoArea({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, 1],
              [2, 3]
            ],
            [
              [4, 5],
              [6, 7]
            ]
          ]
        }),
        equals(0));
  });

  test("area: Polygon - tiny", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [-64.66070178517852, 18.33986913231323],
              [-64.66079715091509, 18.33994007490749],
              [-64.66074946804680, 18.33994007490749],
              [-64.66070178517852, 18.33986913231323]
            ]
          ]
        }),
        closeTo(4.890516e-13, 1e-13));
  });

  test("area: Polygon - zero area", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [96.79142432523281, 5.262704519048153],
              [96.81065389253769, 5.272455576551362],
              [96.82988345984256, 5.272455576551362],
              [96.81065389253769, 5.272455576551362],
              [96.79142432523281, 5.262704519048153]
            ]
          ]
        }),
        equals(0));
  });

  test("area: Polygon - semilune", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [0, 90],
              [90, 0],
              [0, 0]
            ]
          ]
        }),
        closeTo(pi / 2, 1e-6));
  });

  test("area: Polygon - lune", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [0, 90],
              [90, 0],
              [0, -90],
              [0, 0]
            ]
          ]
        }),
        closeTo(pi, 1e-6));
  });

  test("area: Polygon - hemispheres North", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [-90, 0],
              [180, 0],
              [90, 0],
              [0, 0]
            ]
          ]
        }),
        closeTo(2 * pi, 1e-6));
  });

  test("area: Polygon - hemispheres South", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [90, 0],
              [180, 0],
              [-90, 0],
              [0, 0]
            ]
          ]
        }),
        closeTo(2 * pi, 1e-6));
  });

  test("area: Polygon - hemispheres East", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [0, 90],
              [180, 0],
              [0, -90],
              [0, 0]
            ]
          ]
        }),
        closeTo(2 * pi, 1e-6));
  });

  test("area: Polygon - hemispheres West", () {
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            [
              [0, 0],
              [0, -90],
              [180, 0],
              [0, 90],
              [0, 0]
            ]
          ]
        }),
        closeTo(2 * pi, 1e-6));
  });

  test("area: Polygon - graticule outline sphere", () {
    expect(
        geoArea((GeoGraticule()
              ..extent = [
                [-180, -90],
                [180, 90]
              ])
            .outline),
        closeTo(4 * pi, 1e-5));
  });

  test("area: Polygon - graticule outline hemisphere", () {
    expect(
        geoArea((GeoGraticule()
              ..extent = [
                [-180, 0],
                [180, 90]
              ])
            .outline),
        closeTo(2 * pi, 1e-5));
  });

  test("area: Polygon - graticule outline semilune", () {
    expect(
        geoArea((GeoGraticule()
              ..extent = [
                [0, 0],
                [90, 90]
              ])
            .outline),
        closeTo(pi / 2, 1e-5));
  });

  test("area: Polygon - circles hemisphere", () {
    expect(geoArea(GeoCircle()()), closeTo(2 * pi, 1e-5));
  });

  test("area: Polygon - circles 60°", () {
    expect(geoArea(GeoCircle(radius: 60, precision: 0.1)()), closeTo(pi, 1e-5));
  });

  test("area: Polygon - circles 60° North", () {
    expect(geoArea(GeoCircle(radius: 60, precision: 0.1, center: [0, 90])()),
        closeTo(pi, 1e-5));
  });

  test("area: Polygon - circles 45°", () {
    expect(geoArea(GeoCircle(radius: 45, precision: 0.1)()),
        closeTo(pi * (2 - sqrt2), 1e-5));
  });

  test("area: Polygon - circles 45° North", () {
    expect(geoArea(GeoCircle(radius: 45, precision: 0.1, center: [0, 90])()),
        closeTo(pi * (2 - sqrt2), 1e-5));
  });

  test("area: Polygon - circles 45° South", () {
    expect(geoArea(GeoCircle(radius: 45, precision: 0.1, center: [0, -90])()),
        closeTo(pi * (2 - sqrt2), 1e-5));
  });

  test("area: Polygon - circles 135°", () {
    expect(geoArea(GeoCircle(radius: 135, precision: 0.1)()),
        closeTo(pi * (2 + sqrt2), 1e-5));
  });

  test("area: Polygon - circles 135° North", () {
    expect(geoArea(GeoCircle(radius: 135, precision: 0.1, center: [0, 90])()),
        closeTo(pi * (2 + sqrt2), 1e-5));
  });

  test("area: Polygon - circles 135° South", () {
    expect(geoArea(GeoCircle(radius: 135, precision: 0.1, center: [0, -90])()),
        closeTo(pi * (2 + sqrt2), 1e-5));
  });

  test("area: Polygon - circles tiny", () {
    expect(
        geoArea(GeoCircle(radius: 1e-6, precision: 0.1)()), closeTo(0, 1e-6));
  });

  test("area: Polygon - circles huge", () {
    expect(geoArea(GeoCircle(radius: 180 - 1e-6, precision: 0.1)()),
        closeTo(4 * pi, 1e-6));
  });

  test("area: Polygon - circles 60° with 45° hole", () {
    final circle = GeoCircle(precision: 0.1);
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": <List<List<num>>>[
            (circle..radius = 60)()["coordinates"][0],
            ((circle..radius = 45)()["coordinates"][0] as List<List<num>>)
                .reversed
                .toList()
          ]
        }),
        closeTo(pi * (sqrt2 - 1), 1e-5));
  });

  test("area: Polygon - circles 45° holes at [0°, 0°] and [0°, 90°]", () {
    final circle = GeoCircle(precision: 0.1, radius: 45);
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            ((circle..center = [0, 0])()["coordinates"][0] as List<List<num>>)
                .reversed
                .toList(),
            ((circle..center = [0, 90])()["coordinates"][0] as List<List<num>>)
                .reversed
                .toList()
          ]
        }),
        closeTo(pi * 2 * sqrt2, 1e-5));
  });

  test("area: Polygon - circles 45° holes at [0°, 90°] and [0°, 0°]", () {
    final circle = GeoCircle(precision: 0.1, radius: 45);
    expect(
        geoArea({
          "type": "Polygon",
          "coordinates": [
            ((circle..center = [0, 90])()["coordinates"][0] as List<List<num>>)
                .reversed
                .toList(),
            ((circle..center = [0, 0])()["coordinates"][0] as List<List<num>>)
                .reversed
                .toList()
          ]
        }),
        closeTo(pi * 2 * sqrt2, 1e-5));
  });

  test("area: Polygon - stripes 45°, -45°", () {
    expect(geoArea(stripes(45, -45)), closeTo(pi * 2 * sqrt2, 1e-5));
  });

  test("area: Polygon - stripes -45°, 45°", () {
    expect(geoArea(stripes(-45, 45)), closeTo(pi * 2 * (2 - sqrt2), 1e-5));
  });

  test("area: Polygon - stripes 45°, 30°", () {
    expect(geoArea(stripes(45, 30)), closeTo(pi * (sqrt2 - 1), 1e-5));
  });

  test("area: MultiPolygon two hemispheres", () {
    expect(
        geoArea({
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [-90, 0],
                [180, 0],
                [90, 0],
                [0, 0]
              ]
            ],
            [
              [
                [0, 0],
                [90, 0],
                [180, 0],
                [-90, 0],
                [0, 0]
              ]
            ]
          ]
        }),
        equals(4 * pi));
  });

  test("area: Sphere", () {
    expect(geoArea({"type": "Sphere"}), equals(4 * pi));
  });

  test("area: GeometryCollection", () {
    expect(
        geoArea({
          "type": "GeometryCollection",
          "geometries": [
            {"type": "Sphere"}
          ]
        }),
        equals(4 * pi));
  });

  test("area: FeatureCollection", () {
    expect(
        geoArea({
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {"type": "Sphere"}
            }
          ]
        }),
        equals(4 * pi));
  });

  test("area: Feature", () {
    expect(
        geoArea({
          "type": "Feature",
          "geometry": {"type": "Sphere"}
        }),
        equals(4 * pi));
  });
}
