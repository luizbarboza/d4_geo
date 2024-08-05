import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("azimuthal projections don't crash on the antipode", () {
    expect(
        [
          geoAzimuthalEqualArea().call([180, 0]),
          geoAzimuthalEqualArea().call([-180, 0]),
          geoAzimuthalEquidistant().call([180, 0])
        ],
        everyElement([
          inExclusiveRange(double.negativeInfinity, double.infinity),
          inExclusiveRange(double.negativeInfinity, double.infinity)
        ]));
  });
}
