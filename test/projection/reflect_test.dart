import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test("projection.reflectX(…) defaults to false", () {
    final projection = geoGnomonic()
          ..scale = 1
          ..translate = [0, 0],
        projectionEqual = ProjectionEqual(projection);
    expect(projection.reflectX, isFalse);
    expect(projection.reflectY, isFalse);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [0.17632698070846498, 0]
    ], projectionEqual);
    expect([
      [0, 10],
      [0, -0.17632698070846498]
    ], projectionEqual);
  });

  test("projection.reflectX(…) mirrors x after projecting", () {
    final projection = geoGnomonic()
          ..scale = 1
          ..translate = [0, 0]
          ..reflectX = true,
        projectionEqual = ProjectionEqual(projection);
    expect(projection.reflectX, isTrue);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [-0.17632698070846498, 0]
    ], projectionEqual);
    expect([
      [0, 10],
      [0, -0.17632698070846498]
    ], projectionEqual);
    projection
      ..reflectX = false
      ..reflectY = true;
    expect(projection.reflectX, isFalse);
    expect(projection.reflectY, isTrue);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [0.17632698070846498, 0]
    ], projectionEqual);
    expect([
      [0, 10],
      [0, 0.17632698070846498]
    ], projectionEqual);
  });

  test("projection.reflectX(…) works with projection.angle()", () {
    final projection = geoMercator()
          ..scale = 1
          ..translate = [10, 20]
          ..reflectX = true
          ..angle = 45,
        projectionEqual = ProjectionEqual(projection);
    expect(projection.reflectX, isTrue);
    expect(projection.angle, 45);
    expect([
      [0, 0],
      [10, 20]
    ], projectionEqual);
    expect([
      [10, 0],
      [9.87658658, 20.12341341]
    ], projectionEqual);
    expect([
      [0, 10],
      [9.87595521, 19.87595521]
    ], projectionEqual);
  });
}
