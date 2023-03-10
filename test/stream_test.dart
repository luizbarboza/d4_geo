// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("geoStream(object) ignores unknown types", () {
    GeoStream()({"type": "Unknown"});
    GeoStream()({
      "type": "Feature",
      "geometry": {"type": "Unknown"}
    });
    GeoStream()({
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {"type": "Unknown"}
        }
      ]
    });
    GeoStream()({
      "type": "GeometryCollection",
      "geometries": [
        {"type": "Unknown"}
      ]
    });
  });

  test("geoStream(object) ignores null geometries", () {
    GeoStream()(null);
    GeoStream()({"type": "Feature", "geometry": null});
    GeoStream()({
      "type": "FeatureCollection",
      "features": [
        {"type": "Feature", "geometry": null}
      ]
    });
    GeoStream()({
      "type": "GeometryCollection",
      "geometries": [null]
    });
  });

  /*
  test("geoStream(object) returns void", () {
    expect(GeoStream(point: (_, __, [__]) => true)({"type": "Point", "coordinates": [1, 2]}), void);
  });
  */

  test("geoStream(object) allows empty multi-geometries", () {
    GeoStream()({"type": "MultiPoint", "coordinates": []});
    GeoStream()({"type": "MultiLineString", "coordinates": []});
    GeoStream()({"type": "MultiPolygon", "coordinates": []});
  });

  test("geoStream(Sphere) ↦ sphere", () {
    var calls = 0;
    GeoStream(sphere: () {
      //expect(arguments.length, equals(0));
      expect(++calls, equals(1));
    })({"type": "Sphere"});
    expect(calls, 1);
  });

  test("geoStream(Point) ↦ point", () {
    var calls = 0, coordinates = 0;
    GeoStream(point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(++calls, equals(1));
    })({
      "type": "Point",
      "coordinates": [1, 2, 3]
    });
    expect(calls, equals(1));
  });

  test("geoStream(MultiPoint) ↦ point*", () {
    var calls = 0, coordinates = 0;
    GeoStream(point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(1 <= ++calls && calls <= 2, equals(true));
    })({
      "type": "MultiPoint",
      "coordinates": [
        [1, 2, 3],
        [4, 5, 6]
      ]
    });
    expect(calls, equals(2));
  });

  test("geoStream(LineString) ↦ lineStart, point{2,}, lineEnd", () {
    var calls = 0, coordinates = 0;
    GeoStream(lineStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls, equals(1));
    }, point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(2 <= ++calls && calls <= 3, equals(true));
    }, lineEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls, equals(4));
    })({
      "type": "LineString",
      "coordinates": [
        [1, 2, 3],
        [4, 5, 6]
      ]
    });
    expect(calls, equals(4));
  });

  test("geoStream(MultiLineString) ↦ (lineStart, point{2,}, lineEnd)*", () {
    var calls = 0, coordinates = 0;
    GeoStream(lineStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 1 || calls == 5, equals(true));
    }, point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(
          2 <= ++calls && calls <= 3 || 6 <= calls && calls <= 7, equals(true));
    }, lineEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 4 || calls == 8, equals(true));
    })({
      "type": "MultiLineString",
      "coordinates": [
        [
          [1, 2, 3],
          [4, 5, 6]
        ],
        [
          [7, 8, 9],
          [10, 11, 12]
        ]
      ]
    });
    expect(calls, equals(8));
  });

  test(
      "geoStream(Polygon) ↦ polygonStart, lineStart, point{2,}, lineEnd, polygonEnd",
      () {
    var calls = 0, coordinates = 0;
    GeoStream(polygonStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 1, equals(true));
    }, lineStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 2 || calls == 6, equals(true));
    }, point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(
          3 <= ++calls && calls <= 4 || 7 <= calls && calls <= 8, equals(true));
    }, lineEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 5 || calls == 9, equals(true));
    }, polygonEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 10, equals(true));
    })({
      "type": "Polygon",
      "coordinates": [
        [
          [1, 2, 3],
          [4, 5, 6],
          [1, 2, 3]
        ],
        [
          [7, 8, 9],
          [10, 11, 12],
          [7, 8, 9]
        ]
      ]
    });
    expect(calls, equals(10));
  });

  test(
      "geoStream(MultiPolygon) ↦ (polygonStart, lineStart, point{2,}, lineEnd, polygonEnd)*",
      () {
    var calls = 0, coordinates = 0;
    GeoStream(polygonStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 1 || calls == 7, equals(true));
    }, lineStart: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 2 || calls == 8, equals(true));
    }, point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(3 <= ++calls && calls <= 4 || 9 <= calls && calls <= 10,
          equals(true));
    }, lineEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 5 || calls == 11, equals(true));
    }, polygonEnd: () {
      //expect(arguments.length, equals(0));
      expect(++calls == 6 || calls == 12, equals(true));
    })({
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [1, 2, 3],
            [4, 5, 6],
            [1, 2, 3]
          ]
        ],
        [
          [
            [7, 8, 9],
            [10, 11, 12],
            [7, 8, 9]
          ]
        ]
      ]
    });
    expect(calls, equals(12));
  });

  test("geoStream(Feature) ↦ .*", () {
    var calls = 0, coordinates = 0;
    GeoStream(point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(++calls, equals(1));
    })({
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [1, 2, 3]
      }
    });
    expect(calls, equals(1));
  });

  test("geoStream(FeatureCollection) ↦ .*", () {
    var calls = 0, coordinates = 0;
    GeoStream(point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(++calls, equals(1));
    })({
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [1, 2, 3]
          }
        }
      ]
    });
    expect(calls, equals(1));
  });

  test("geoStream(GeometryCollection) ↦ .*", () {
    var calls = 0, coordinates = 0;
    GeoStream(point: (p) {
      //expect(arguments.length, equals(3));
      expect(p[0], equals(++coordinates));
      expect(p[1], equals(++coordinates));
      expect(p[2], equals(++coordinates));
      expect(++calls, equals(1));
    })({
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "Point",
          "coordinates": [1, 2, 3]
        }
      ]
    });
    expect(calls, equals(1));
  });
}
