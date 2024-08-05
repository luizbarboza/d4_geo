import 'adder.dart';
import 'math.dart';
import 'noop.dart';
import 'path/path.dart';
import 'stream.dart';

late Adder _lengthSum;
late num _lambda0;
late double _sinPhi0, _cosPhi0;

final _lengthStream = GeoStream(lineStart: _lengthLineStart);

void _lengthLineStart() {
  _lengthStream.point = _lengthPointFirst;
  _lengthStream.lineEnd = _lengthLineEnd;
}

void _lengthLineEnd() {
  _lengthStream.point = _lengthStream.lineEnd = noop;
}

void _lengthPointFirst(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  _lambda0 = lambda;
  _sinPhi0 = sin(phi);
  _cosPhi0 = cos(phi);
  _lengthStream.point = _lengthPoint;
}

void _lengthPoint(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  var sinPhi = sin(phi),
      cosPhi = cos(phi),
      delta = abs(lambda - _lambda0),
      cosDelta = cos(delta),
      sinDelta = sin(delta),
      x = cosPhi * sinDelta,
      y = _cosPhi0 * sinPhi - _sinPhi0 * cosPhi * cosDelta,
      z = _sinPhi0 * sinPhi + _cosPhi0 * cosPhi * cosDelta;
  _lengthSum.add(atan2(sqrt(x * x + y * y), z));
  _lambda0 = lambda;
  _sinPhi0 = sinPhi;
  _cosPhi0 = cosPhi;
}

/// Returns the great-arc length of the specified GeoJSON *object* in
/// [radians](http://mathworld.wolfram.com/Radian.html).
///
/// For polygons, returns the perimeter of the exterior ring plus that of any
/// interior rings. This is the spherical equivalent of [GeoPath.measure].
///
/// {@category Spherical math}
double geoLength(Map object) {
  _lengthSum = Adder();
  _lengthStream(object);
  return _lengthSum.valueOf();
}
