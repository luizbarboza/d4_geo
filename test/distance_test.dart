// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test(
      "distance(a, b) computes the great-arc distance in radians between the two points a and b",
      () {
    expect(geoDistance([0, 0], [0, 0]), equals(0));
    expect(
        geoDistance(
            [118 + 24 / 60, 33 + 57 / 60], [73 + 47 / 60, 40 + 38 / 60]),
        closeTo(3973 / 6371, 0.5));
  });

  test("distance(a, b) correctly computes small distances", () {
    expect(geoDistance([0, 0], [0, 1e-12]), greaterThan(0));
  });
}
