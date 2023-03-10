// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("a rotation of a degenerate polygon should not break", () {
    final projection = geoMercator()
      ..rotate = [-134.300, 25.776]
      ..scale = 750
      ..translate = [0, 0];
    expect(
        normalizePath(GeoPath(projection)({
          "type": "Polygon",
          "coordinates": [
            [
              [125.67351590459046, -14.17673705310531],
              [125.67351590459046, -14.173276873687367],
              [125.67351590459046, -14.173276873687367],
              [125.67351590459046, -14.169816694269425],
              [125.67351590459046, -14.17673705310531]
            ]
          ]
        }) as String),
        "M-111.644162,-149.157654L-111.647235,-149.203744L-111.647235,-149.203744L-111.650307,-149.249835Z");
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
