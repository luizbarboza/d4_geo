import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

void main() {
  test("a rotation of [+90°, 0°] only rotates longitude", () {
    final rotation = GeoRotation([90, 0]).forward([0, 0]);
    expect(rotation[0], closeTo(90, 1e-6));
    expect(rotation[1], closeTo(0, 1e-6));
  });

  test("a rotation of [+90°, 0°] wraps around when crossing the antimeridian",
      () {
    final rotation = GeoRotation([90, 0]).forward([150, 0]);
    expect(rotation[0], closeTo(-120, 1e-6));
    expect(rotation[1], closeTo(0, 1e-6));
  });

  test("a rotation of [-45°, 45°] rotates longitude and latitude", () {
    final rotation = GeoRotation([-45, 45]).forward([0, 0]);
    expect(rotation[0], closeTo(-54.73561, 1e-6));
    expect(rotation[1], closeTo(30, 1e-6));
  });

  test("a rotation of [-45°, 45°] inverse rotation of longitude and latitude",
      () {
    final rotation = GeoRotation([-45, 45]).backward!([-54.73561, 30]);
    expect(rotation[0], closeTo(0, 1e-6));
    expect(rotation[1], closeTo(0, 1e-6));
  });

  test("the identity rotation constrains longitudes to [-180°, 180°]", () {
    final rotate = GeoRotation([0, 0]);
    expect(rotate.forward([180, 0])[0], equals(180));
    expect(rotate.forward([-180, 0])[0], equals(-180));
    expect(rotate.forward([360, 0])[0], equals(0));
    expect(rotate.forward([2562, 0])[0], closeTo(42, 1e-10));
    expect(rotate.forward([-2562, 0])[0], closeTo(-42, 1e-10));
  });
}
