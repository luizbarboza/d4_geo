// ignore_for_file: lines_longer_than_80_chars

import 'package:test/expect.dart';

class ProjectionEqual extends CustomMatcher {
  dynamic projection;

  ProjectionEqual(this.projection, [double? delta])
      : super(
            '[location, point] that differs from [invert(point), projection(location)] by',
            'difference of [invert(point), projection(location)]',
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
    var l0 = projection.invert(actual[1]),
        l1 = actual[0],
        p0 = projection.call(actual[0]),
        p1 = actual[1];
    return [
      [(l0![0] - l1[0]).abs() % 360, (l0[1] - l1[1]).abs()],
      [(p0[0] - p1[0]).abs(), (p0[1] - p1[1]).abs()]
    ];
  }
}
