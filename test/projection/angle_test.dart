import 'dart:math';

import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test("projection.angle(…) defaults to zero", () {
    final projection = geoGnomonic()
          ..scale = 1
          ..translate = [0, 0],
        projectionEqual = ProjectionEqual(projection);
    expect(projection.angle, 0);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [0.17632698070846498, 0]
    ], projectionEqual);
    expect([
      [-10, 0],
      [-0.17632698070846498, 0]
    ], projectionEqual);
    expect([
      [0, 10],
      [0, -0.17632698070846498]
    ], projectionEqual);
    expect([
      [0, -10],
      [0, 0.17632698070846498]
    ], projectionEqual);
    expect([
      [10, 10],
      [0.17632698070846495, -0.17904710860483972]
    ], projectionEqual);
    expect([
      [10, -10],
      [0.17632698070846495, 0.17904710860483972]
    ], projectionEqual);
    expect([
      [-10, 10],
      [-0.17632698070846495, -0.17904710860483972]
    ], projectionEqual);
    expect([
      [-10, -10],
      [-0.17632698070846495, 0.17904710860483972]
    ], projectionEqual);
  });

  test("projection.angle(…) rotates by the specified degrees after projecting",
      () {
    final projection = geoGnomonic()
          ..scale = 1
          ..translate = [0, 0]
          ..angle = 30,
        projectionEqual = ProjectionEqual(projection);
    expect(projection.angle, closeTo(30, 1e-6));
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [0.1527036446661393, -0.08816349035423247]
    ], projectionEqual);
    expect([
      [-10, 0],
      [-0.1527036446661393, 0.08816349035423247]
    ], projectionEqual);
    expect([
      [0, 10],
      [-0.08816349035423247, -0.1527036446661393]
    ], projectionEqual);
    expect([
      [0, -10],
      [0.08816349035423247, 0.1527036446661393]
    ], projectionEqual);
    expect([
      [10, 10],
      [0.06318009036371944, -0.24322283488017502]
    ], projectionEqual);
    expect([
      [10, -10],
      [0.24222719896855913, 0.0668958541717101]
    ], projectionEqual);
    expect([
      [-10, 10],
      [-0.24222719896855913, -0.0668958541717101]
    ], projectionEqual);
    expect([
      [-10, -10],
      [-0.06318009036371944, 0.24322283488017502]
    ], projectionEqual);
  });

  test(
      "projection.angle(…) rotates by the specified degrees after projecting 2",
      () {
    final projection = geoGnomonic()
          ..scale = 1
          ..translate = [0, 0]
          ..angle = -30,
        projectionEqual = ProjectionEqual(projection);
    expect(projection.angle, closeTo(-30, 1e-6));
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [10, 0],
      [0.1527036446661393, 0.08816349035423247]
    ], projectionEqual);
    expect([
      [-10, 0],
      [-0.1527036446661393, -0.08816349035423247]
    ], projectionEqual);
    expect([
      [0, 10],
      [0.08816349035423247, -0.1527036446661393]
    ], projectionEqual);
    expect([
      [0, -10],
      [-0.08816349035423247, 0.1527036446661393]
    ], projectionEqual);
    expect([
      [10, 10],
      [0.24222719896855913, -0.0668958541717101]
    ], projectionEqual);
    expect([
      [10, -10],
      [0.06318009036371944, 0.24322283488017502]
    ], projectionEqual);
    expect([
      [-10, 10],
      [-0.06318009036371944, -0.24322283488017502]
    ], projectionEqual);
    expect([
      [-10, -10],
      [-0.24222719896855913, 0.0668958541717101]
    ], projectionEqual);
  });

  test("projection.angle(…) wraps around 360°", () {
    final projection = geoGnomonic()
      ..scale = 1
      ..translate = [0, 0]
      ..angle = 360;
    expect(projection.angle, 0);
  });

  test("identity.angle(…) rotates geoIdentity", () {
    final projection = GeoIdentity()..angle = -45,
        sqrt2 = sqrt(2) / 2,
        projectionEqual = ProjectionEqual(projection);
    expect(projection.angle, closeTo(-45, 1e-6));
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [1, 0],
      [sqrt2, sqrt2]
    ], projectionEqual);
    expect([
      [-1, 0],
      [-sqrt2, -sqrt2]
    ], projectionEqual);
    expect([
      [0, 1],
      [-sqrt2, sqrt2]
    ], projectionEqual);
  });
}
