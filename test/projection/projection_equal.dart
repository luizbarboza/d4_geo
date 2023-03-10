// ignore_for_file: lines_longer_than_80_chars

import 'package:d4_geo/d4_geo.dart';
import 'package:test/expect.dart';

class ProjectionEqual extends CustomMatcher {
  GeoProjection projection;

  ProjectionEqual(this.projection, [double? delta])
      : super(
            '[location, point] that differs from [backward(point), forward(location)] by',
            'difference of [backward(point), forward(location)]',
            equals([
              [
                anyOf(lessThanOrEqualTo(delta ?? 1e-3),
                    greaterThanOrEqualTo(360 - (delta ?? 1e-3))),
                lessThanOrEqualTo(delta ?? 1e-3)
              ],
              [
                lessThanOrEqualTo(delta ?? 1e-6),
                lessThanOrEqualTo(delta ?? 1e-6)
              ]
            ]));

  @override
  featureValueOf(actual) {
    var l0 = projection.backward!(actual[1]),
        l1 = actual[0],
        p0 = projection.forward(actual[0]),
        p1 = actual[1];
    return [
      [(l0[0] - l1[0]).abs() % 360, (l0[1] - l1[1]).abs()],
      [(p0[0] - p1[0]).abs(), (p0[1] - p1[1]).abs()]
    ];
  }
}
