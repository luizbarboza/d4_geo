import 'adder.dart';
import 'math.dart';
import 'noop.dart';
import 'path/path.dart';
import 'stream.dart';

Adder _areaSum = Adder(), areaRingSum = Adder();
late num _lambda00, _phi00;
late num _lambda0, _cosPhi0, _sinPhi0;

void _areaRingStart() {
  areaStream.point = _areaPointFirst;
}

void _areaRingEnd() {
  _areaPoint(_lambda00, _phi00);
}

void _areaPointFirst(num lambda, num phi, [_]) {
  areaStream.point = _areaPoint;
  _lambda00 = lambda;
  _phi00 = phi;
  lambda *= radians;
  phi *= radians;
  _lambda0 = lambda;
  _cosPhi0 = cos(phi = phi / 2 + quarterPi);
  _sinPhi0 = sin(phi);
}

void _areaPoint(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  phi = phi / 2 + quarterPi; // half the angular distance from south pole

  // Spherical excess E for a spherical triangle with vertices: south pole,
  // previous point, current point.  Uses a formula derived from Cagnoli’s
  // theorem.  See Todhunter, Spherical Trig. (1871), Sec. 103, Eq. (2).
  num dLambda = lambda - _lambda0,
      sdLambda = dLambda >= 0 ? 1 : -1,
      adLambda = sdLambda * dLambda,
      cosPhi = cos(phi),
      sinPhi = sin(phi),
      k = _sinPhi0 * sinPhi,
      u = _cosPhi0 * cosPhi + k * cos(adLambda),
      v = k * sdLambda * sin(adLambda);
  areaRingSum.add(atan2(v, u));

  // Advance the previous points.
  _lambda0 = lambda;
  _cosPhi0 = cosPhi;
  _sinPhi0 = sinPhi;
}

GeoStream areaStream = GeoStream(polygonStart: () {
  areaRingSum = Adder();
  areaStream.lineStart = _areaRingStart;
  areaStream.lineEnd = _areaRingEnd;
}, polygonEnd: () {
  var areaRing = areaRingSum.valueOf();
  _areaSum.add(areaRing < 0 ? tau + areaRing : areaRing);
  areaStream.lineStart = areaStream.lineEnd = areaStream.point = noop;
}, sphere: () {
  _areaSum.add(tau);
});

/// Returns the spherical area of the specified GeoJSON *object* in
/// [steradians](https://en.wikipedia.org/wiki/Steradian).
///
/// This is the spherical equivalent of [GeoPath.area].
///
/// {@category Spherical math}
double geoArea(Map object) {
  _areaSum = Adder();
  areaStream(object);
  return _areaSum.valueOf() * 2;
}
