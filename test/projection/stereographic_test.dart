import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test("stereographic(point) returns the expected result", () {
    final stereographic = geoStereographic()
          ..translate = [0, 0]
          ..scale = 1,
        projectionEqual = ProjectionEqual(stereographic);
    expect([
      [0, 0],
      [0, 0]
    ], projectionEqual);
    expect([
      [-90, 0],
      [-1, 0]
    ], projectionEqual);
    expect([
      [90, 0],
      [1, 0]
    ], projectionEqual);
    expect([
      [0, -90],
      [0, 1]
    ], projectionEqual);
    expect([
      [0, 90],
      [0, -1]
    ], projectionEqual);
  });
}
