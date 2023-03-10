// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("geoInterpolate(a, a) returns a", () {
    expect(geoInterpolate([140.63289, -29.95101], [140.63289, -29.95101])(0.5),
        [140.63289, -29.95101]);
  });

  test(
      "geoInterpolate(a, b) returns the expected values when a and b lie on the equator",
      () {
    expect(geoInterpolate([10, 0], [20, 0])(0.5),
        [15, 0].map((a) => closeTo(a, 1e-6)));
  });

  test(
      "geoInterpolate(a, b) returns the expected values when a and b lie on a meridian",
      () {
    expect(geoInterpolate([10, -20], [10, 40])(0.5),
        [10, 10].map((a) => closeTo(a, 1e-6)));
  });
}
