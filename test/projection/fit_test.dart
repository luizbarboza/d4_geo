import 'dart:io';
import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart';
import 'package:topo_parse/topo_parse.dart';

void main() {
  final usTopo =
      parseString(File("./test/data/us-10m.json").readAsStringSync());
  final us = feature(usTopo, usTopo["objects"]["land"]);
  final worldTopo =
      parseString(File("./test/data/world-50m.json").readAsStringSync());
  final world = feature(worldTopo, worldTopo["objects"]["land"]);

  test("projection.fitExtent(…) sphere equirectangular", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], {
        "type": "Sphere"
      });
    expect(projection.scale, closeTo(900 / (2 * pi), 1e-6));
    expect(projection.translate, [500, 500].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world equirectangular", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [500, 492.000762].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world azimuthalEqualArea", () {
    final projection = geoAzimuthalEqualArea()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(228.357229, 1e-6));
    expect(projection.translate,
        [496.353618, 479.684353].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world azimuthalEquidistant", () {
    final projection = geoAzimuthalEquidistant()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(153.559317, 1e-6));
    expect(projection.translate,
        [485.272493, 452.093375].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world conicConformal", () {
    final projection = geoConicConformal()
      ..clipAngle = 30
      ..parallels = [30, 60]
      ..rotate = [0, -45]
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(626.111027, 1e-6));
    expect(projection.translate,
        [444.395951, 410.223799].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world conicEqualArea", () {
    final projection = geoConicEqualArea()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(145.862346, 1e-6));
    expect(
        projection.translate, [500, 498.0114265].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world conicEquidistant", () {
    final projection = geoConicEquidistant()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(123.085587, 1e-6));
    expect(
        projection.translate, [500, 498.598401].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitSize(…) world equirectangular", () {
    final projection = geoEquirectangular()..fitSize([900, 900], world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [450, 442.000762].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world gnomonic", () {
    final projection = geoGnomonic()
      ..clipAngle = 45
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(450.348233, 1e-6));
    expect(projection.translate,
        [500.115138, 556.522620].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world mercator", () {
    final projection = geoMercator()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [500, 481.549457].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world orthographic", () {
    final projection = geoOrthographic()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(451.406773, 1e-6));
    expect(projection.translate,
        [503.769179, 498.593227].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitSize(…) world orthographic", () {
    final projection = geoOrthographic()..fitSize([900, 900], world);
    expect(projection.scale, closeTo(451.406773, 1e-6));
    expect(projection.translate,
        [453.769179, 448.593227].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world stereographic", () {
    final projection = geoStereographic()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(162.934379, 1e-6));
    expect(projection.translate,
        [478.546293, 432.922534].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) world transverseMercator", () {
    final projection = GeoTransverseMercator()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [473.829551, 500].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) USA albersUsa", () {
    final projection = GeoAlbersUsa()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], us);
    expect(projection.scale, closeTo(1152.889035, 1e-6));
    expect(projection.translate,
        [533.52541, 496.232028].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitExtent(…) null geometries - Feature", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], {
        "type": "Feature",
        "geometry": null
      });
    final s = projection.scale, t = projection.translate;
    expect(s, isZero);
    expect(t[0], isNaN);
    expect(t[1], isNaN);
  });

  test("projection.fitExtent(…) null geometries - MultiPoint", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], {
        "type": "MultiPoint",
        "coordinates": []
      });
    final s = projection.scale, t = projection.translate;
    expect(s, isZero);
    expect(t[0], isNaN);
    expect(t[1], isNaN);
  });

  test("projection.fitExtent(…) null geometries - MultiLineString", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], {
        "type": "MultiLineString",
        "coordinates": []
      });
    final s = projection.scale, t = projection.translate;
    expect(s, isZero);
    expect(t[0], isNaN);
    expect(t[1], isNaN);
  });

  test("projection.fitExtent(…) null geometries - MultiPolygon", () {
    final projection = geoEquirectangular()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], {
        "type": "MultiPolygon",
        "coordinates": []
      });
    final s = projection.scale, t = projection.translate;
    expect(s, isZero);
    expect(t[0], isNaN);
    expect(t[1], isNaN);
  });

  test("projection.fitExtent(…) custom projection", () {
    final projection =
        GeoProjection(GeoRawTransform((p) => [p[0], pow(p[1], 3)]))
          ..fitExtent([
            [50, 50],
            [950, 950]
          ], world);
    expect(projection.scale, closeTo(128.903525, 1e-6));
    expect(
        projection.translate, [500, 450.414357].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitSize(…) ignore clipExtent - world equirectangular", () {
    final p1 = geoEquirectangular()..fitSize([1000, 1000], world);
    final s1 = p1.scale;
    final t1 = p1.translate;
    final c1 = p1.clipExtent;
    final p2 = geoEquirectangular()
      ..clipExtent = [
        [100, 200],
        [700, 600]
      ]
      ..fitSize([1000, 1000], world);
    final s2 = p2.scale;
    final t2 = p2.translate;
    final c2 = p2.clipExtent;
    expect(s1, closeTo(s2, 1e-6));
    expect(t1, t2.map((a) => closeTo(a, 1e-6)));
    expect(c1, isNull);
    expect(c2, [
      [100, 200],
      [700, 600]
    ]);
  });

  test("projection.fitExtent(…) chaining - world transverseMercator", () {
    final projection = GeoTransverseMercator()
      ..fitExtent([
        [50, 50],
        [950, 950]
      ], world)
      ..scale = 500;
    expect(projection.scale, 500);
    expect(
        projection.translate, [473.829551, 500].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitSize(…) resampling - world mercator", () {
    const box = {
      "type": "Polygon",
      "coordinates": [
        [
          [-135, 45],
          [-45, 45],
          [-45, -45],
          [-135, -45],
          [-135, 45]
        ]
      ]
    };
    final p1 = geoMercator()
      ..precision = 0.1
      ..fitSize([1000, 1000], box);
    final p2 = geoMercator()
      ..precision = 0
      ..fitSize([1000, 1000], box);
    final t1 = p1.translate;
    final t2 = p2.translate;
    expect(p1.precision, 0.1);
    expect(p2.precision, 0);
    expect(p1.scale, closeTo(436.218018, 1e-6));
    expect(p2.scale, closeTo(567.296328, 1e-6));
    expect(t1[0], closeTo(1185.209661, 1e-6));
    expect(t2[0], closeTo(1391.106989, 1e-6));
    expect(t1[1], closeTo(500, 1e-6));
    expect(t1[1], closeTo(t2[1], 1e-6));
  });

  test("projection.fitWidth(…) world equirectangular", () {
    final projection = geoEquirectangular()..fitWidth(900, world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [450, 208.999023].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitWidth(…) world transverseMercator", () {
    final projection = GeoTransverseMercator()..fitWidth(900, world);
    expect(projection.scale, closeTo(166.239257, 1e-6));
    expect(projection.translate,
        [419.627390, 522.256029].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitWidth(…) USA albersUsa", () {
    final projection = GeoAlbersUsa()..fitWidth(900, us);
    expect(projection.scale, closeTo(1152.889035, 1e-6));
    expect(projection.translate,
        [483.52541, 257.736905].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitHeight(…) world equirectangular", () {
    final projection = geoEquirectangular()..fitHeight(900, world);
    expect(projection.scale, closeTo(297.042711, 1e-6));
    expect(projection.translate,
        [933.187199, 433.411585].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitHeight(…) world transverseMercator", () {
    final projection = GeoTransverseMercator()..fitHeight(900, world);
    expect(projection.scale, closeTo(143.239449, 1e-6));
    expect(
        projection.translate, [361.570408, 450].map((a) => closeTo(a, 1e-6)));
  });

  test("projection.fitHeight(…) USA albersUsa", () {
    final projection = GeoAlbersUsa()..fitHeight(900, us);
    expect(projection.scale, closeTo(1983.902059, 1e-6));
    expect(projection.translate,
        [832.054974, 443.516038].map((a) => closeTo(a, 1e-6)));
  });
}
