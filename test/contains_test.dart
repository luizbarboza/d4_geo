import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("a sphere contains any point", () {
    expect(geoContains({"type": "Sphere"}, [0, 0]), equals(true));
  });

  test("a point contains itself (and not some other point)", () {
    expect(
        geoContains({
          "type": "Point",
          "coordinates": [0, 0]
        }, [
          0,
          0
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "Point",
          "coordinates": [1, 2]
        }, [
          1,
          2
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "Point",
          "coordinates": [0, 0]
        }, [
          0,
          1
        ]),
        equals(false));
    expect(
        geoContains({
          "type": "Point",
          "coordinates": [1, 1]
        }, [
          1,
          0
        ]),
        equals(false));
  });

  test("a MultiPoint contains any of its points", () {
    expect(
        geoContains({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, [
          0,
          0
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, [
          1,
          2
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "MultiPoint",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, [
          1,
          3
        ]),
        equals(false));
  });

  test("a LineString contains any point on the Great Circle path", () {
    expect(
        geoContains({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, [
          0,
          0
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, [
          1,
          2
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, geoInterpolate([0, 0], [1, 2])(0.3)),
        equals(true));
    expect(
        geoContains({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, geoInterpolate([0, 0], [1, 2])(1.3)),
        equals(false));
    expect(
        geoContains({
          "type": "LineString",
          "coordinates": [
            [0, 0],
            [1, 2]
          ]
        }, geoInterpolate([0, 0], [1, 2])(-0.3)),
        equals(false));
  });

  test("a LineString with 2+ points contains those points", () {
    const points = [
      [0, 0],
      [1, 2],
      [3, 4],
      [5, 6]
    ];
    const feature = {"type": "LineString", "coordinates": points};
    for (final point in points) {
      expect(geoContains(feature, point), equals(true));
    }
  });

  test("a LineString contains epsilon-distant points", () {
    const epsilon = 1e-6;
    const line = [
      [0, 0],
      [0, 10],
      [10, 10],
      [10, 0]
    ];
    const points = [
      [0, 5],
      [epsilon * 1, 5],
      [0, epsilon],
      [epsilon * 1, epsilon]
    ];
    for (final point in points) {
      expect(geoContains({"type": "LineString", "coordinates": line}, point),
          equals(true));
    }
  });

  test("a LineString does not contain 10*epsilon-distant points", () {
    const epsilon = 1e-6;
    const line = [
      [0, 0],
      [0, 10],
      [10, 10],
      [10, 0]
    ];
    const points = [
      [epsilon * 10, 5],
      [epsilon * 10, epsilon]
    ];
    for (final point in points) {
      expect(geoContains({"type": "LineString", "coordinates": line}, point),
          false);
    }
  });

  test("a MultiLineString contains any point on one of its components", () {
    expect(
        geoContains({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, 0],
              [1, 2]
            ],
            [
              [2, 3],
              [4, 5]
            ]
          ]
        }, [
          2,
          3
        ]),
        equals(true));
    expect(
        geoContains({
          "type": "MultiLineString",
          "coordinates": [
            [
              [0, 0],
              [1, 2]
            ],
            [
              [2, 3],
              [4, 5]
            ]
          ]
        }, [
          5,
          6
        ]),
        equals(false));
  });

  test("a Polygon contains a point", () {
    final polygon = (GeoCircle()..radius = 60)();
    expect(geoContains(polygon, [1, 1]), equals(true));
    expect(geoContains(polygon, [-180, 0]), equals(false));
  });

  test("a Polygon with a hole doesn't contain a point", () {
    final outer = (GeoCircle()..radius = 60)()["coordinates"][0],
        inner = (GeoCircle()..radius = 3)()["coordinates"][0],
        polygon = {
          "type": "Polygon",
          "coordinates": [outer, inner]
        };
    expect(geoContains(polygon, [1, 1]), equals(false));
    expect(geoContains(polygon, [5, 0]), equals(true));
    expect(geoContains(polygon, [65, 0]), equals(false));
  });

  test("a MultiPolygon contains a point", () {
    final p1 = (GeoCircle()..radius = 6)()["coordinates"],
        p2 = (GeoCircle()
          ..radius = 6
          ..center = [90, 0])()["coordinates"],
        polygon = {
          "type": "MultiPolygon",
          "coordinates": [p1, p2]
        };
    expect(geoContains(polygon, [1, 0]), equals(true));
    expect(geoContains(polygon, [90, 1]), equals(true));
    expect(geoContains(polygon, [90, 45]), equals(false));
  });

  test("a GeometryCollection contains a point", () {
    const collection = {
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
    };
    expect(geoContains(collection, [-45, 0]), equals(true));
    expect(geoContains(collection, [45, 0]), equals(true));
    expect(geoContains(collection, [12, 25]), equals(false));
  });

  test("a Feature contains a point", () {
    const feature = {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [0, 0],
          [45, 0]
        ]
      }
    };
    expect(geoContains(feature, [45, 0]), equals(true));
    expect(geoContains(feature, [12, 25]), equals(false));
  });

  test("a FeatureCollection contains a point", () {
    const feature1 = {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": [
              [0, 0],
              [45, 0]
            ]
          }
        },
        feature2 = {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": [
              [-45, 0],
              [0, 0]
            ]
          }
        },
        featureCollection = {
          "type": "FeatureCollection",
          "features": [feature1, feature2]
        };
    expect(geoContains(featureCollection, [45, 0]), equals(true));
    expect(geoContains(featureCollection, [-45, 0]), equals(true));
    expect(geoContains(featureCollection, [12, 25]), equals(false));
  });

  test("null contains nothing", () {
    expect(geoContains(null, [0, 0]), equals(false));
  });
}
