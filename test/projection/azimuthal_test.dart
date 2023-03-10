import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("azimuthal projections don't crash on the antipode", () {
    expect(
        [
          geoAzimuthalEqualArea().forward([180, 0]),
          geoAzimuthalEqualArea().forward([-180, 0]),
          geoAzimuthalEquidistant().forward([180, 0])
        ],
        everyElement([
          inExclusiveRange(double.negativeInfinity, double.infinity),
          inExclusiveRange(double.negativeInfinity, double.infinity)
        ]));
  });
}
