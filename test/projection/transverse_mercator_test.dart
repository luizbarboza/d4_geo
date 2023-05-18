// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test(
      "transverseMercator.clipExtent(null) sets the default automatic clip extent",
      () {
    final projection = GeoTransverseMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..clipExtent = null
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M3.141593,3.141593L0,3.141593L-3.141593,3.141593L-3.141593,-3.141593L-3.141593,-3.141593L0,-3.141593L3.141593,-3.141593L3.141593,3.141593Z");
    expect(projection.clipExtent, isNull);
  });

  test(
      "transverseMercator.center(center) sets the correct automatic clip extent",
      () {
    final projection = GeoTransverseMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..center = [10, 10]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M2.966167,3.316126L-0.175426,3.316126L-3.317018,3.316126L-3.317019,-2.967060L-3.317019,-2.967060L-0.175426,-2.967060L2.966167,-2.967060L2.966167,3.316126Z");
    expect(projection.clipExtent, isNull);
  });

  test(
      "transverseMercator.clipExtent(extent) intersects the specified clip extent with the automatic clip extent",
      () {
    final projection = GeoTransverseMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M10,3.141593L0,3.141593L-10,3.141593L-10,-3.141593L-10,-3.141593L0,-3.141593L10,-3.141593L10,3.141593Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test(
      "transverseMercator.clipExtent(extent).scale(scale) updates the intersected clip extent",
      () {
    final projection = GeoTransverseMercator()
      ..translate = [0, 0]
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..scale = 1
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M10,3.141593L0,3.141593L-10,3.141593L-10,-3.141593L-10,-3.141593L0,-3.141593L10,-3.141593L10,3.141593Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test(
      "transverseMercator.clipExtent(extent).translate(translate) updates the intersected clip extent",
      () {
    final projection = GeoTransverseMercator()
      ..scale = 1
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..translate = [0, 0]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M10,3.141593L0,3.141593L-10,3.141593L-10,-3.141593L-10,-3.141593L0,-3.141593L10,-3.141593L10,3.141593Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test("transverseMercator.rotate(…) does not affect the automatic clip extent",
      () {
    final projection = GeoTransverseMercator(),
        object = {
          "type": "MultiPoint",
          "coordinates": [
            [-82.35024908550241, 29.649391549778745],
            [-82.35014449996858, 29.65075946917633],
            [-82.34916073446641, 29.65070265688781],
            [-82.3492653331286, 29.64933474064504]
          ]
        };
    projection.fitExtent([
      [0, 0],
      [960, 600]
    ], object);
    var scale = projection.scale, translate = projection.translate;
    projection
      ..rotate = [0, 95]
      ..fitExtent([
        [0, 0],
        [960, 600]
      ], object);
    expect(projection.scale, scale);
    expect(projection.translate[0], translate[0]);
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
