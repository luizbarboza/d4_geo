// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("mercator.clipExtent(null) sets the default automatic clip extent", () {
    final projection = geoMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..clipExtent = null
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M3.141593,-3.141593L3.141593,0L3.141593,3.141593L3.141593,3.141593L-3.141593,3.141593L-3.141593,3.141593L-3.141593,0L-3.141593,-3.141593L-3.141593,-3.141593L3.141593,-3.141593Z");
    expect(projection.clipExtent, isNull);
  });

  test("mercator.center(center) sets the correct automatic clip extent", () {
    final projection = geoMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..center = [10, 10]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M2.967060,-2.966167L2.967060,0.175426L2.967060,3.317018L2.967060,3.317018L-3.316126,3.317018L-3.316126,3.317019L-3.316126,0.175426L-3.316126,-2.966167L-3.316126,-2.966167L2.967060,-2.966167Z");
    expect(projection.clipExtent, null);
  });

  test(
      "mercator.clipExtent(extent) intersects the specified clip extent with the automatic clip extent",
      () {
    final projection = geoMercator()
      ..translate = [0, 0]
      ..scale = 1
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M3.141593,-10L3.141593,0L3.141593,10L3.141593,10L-3.141593,10L-3.141593,10L-3.141593,0L-3.141593,-10L-3.141593,-10L3.141593,-10Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test(
      "mercator.clipExtent(extent).scale(scale) updates the intersected clip extent",
      () {
    final projection = geoMercator()
      ..translate = [0, 0]
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..scale = 1
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M3.141593,-10L3.141593,0L3.141593,10L3.141593,10L-3.141593,10L-3.141593,10L-3.141593,0L-3.141593,-10L-3.141593,-10L3.141593,-10Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test(
      "mercator.clipExtent(extent).translate(translate) updates the intersected clip extent",
      () {
    final projection = geoMercator()
      ..scale = 1
      ..clipExtent = [
        [-10, -10],
        [10, 10]
      ]
      ..translate = [0, 0]
      ..precision = 0;
    expect(normalizePath(GeoPath(projection)({"type": "Sphere"}) as String),
        "M3.141593,-10L3.141593,0L3.141593,10L3.141593,10L-3.141593,10L-3.141593,10L-3.141593,0L-3.141593,-10L-3.141593,-10L3.141593,-10Z");
    expect(projection.clipExtent, [
      [-10, -10],
      [10, 10]
    ]);
  });

  test("mercator.rotate(…) does not affect the automatic clip extent", () {
    final projection = geoMercator(),
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
    expect(projection.scale, 20969742.365692537);
    expect(projection.translate, [30139734.76760269, 11371473.949706702]);
    projection
      ..rotate = [0, 95]
      ..fitExtent([
        [0, 0],
        [960, 600]
      ], object);
    expect(projection.scale, 35781690.650920525);
    expect(projection.translate,
        [closeTo(75115911.95344563, 1e-7), 2586046.4116968135]);
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
