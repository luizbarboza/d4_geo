import 'adder.dart';
import 'math.dart';
import 'path/path.dart';
import 'stream.dart';

late double _w0, _w1, _x0, _y0, _z0, _x1, _y1, _z1;
late Adder _x2, _y2, _z2;
late num _lambda00, _phi00; // first point
late double __x0, __y0, __z0; // previous point

void _centroidPoint(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  var cosPhi = cos(phi);
  _centroidPointCartesian(cosPhi * cos(lambda), cosPhi * sin(lambda), sin(phi));
}

void _centroidPointCartesian(double x, double y, double z) {
  ++_w0;
  _x0 += (x - _x0) / _w0;
  _y0 += (y - _y0) / _w0;
  _z0 += (z - _z0) / _w0;
}

void _centroidLineStart() {
  _centroidStream.point = _centroidLinePointFirst;
}

void _centroidLinePointFirst(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  var cosPhi = cos(phi);
  __x0 = cosPhi * cos(lambda);
  __y0 = cosPhi * sin(lambda);
  __z0 = sin(phi);
  _centroidStream.point = _centroidLinePoint;
  _centroidPointCartesian(__x0, __y0, __z0);
}

void _centroidLinePoint(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  var cosPhi = cos(phi),
      x = cosPhi * cos(lambda),
      y = cosPhi * sin(lambda),
      z = sin(phi),
      w;
  w = atan2(
      sqrt((w = __y0 * z - __z0 * y) * w +
          (w = __z0 * x - __x0 * z) * w +
          (w = __x0 * y - __y0 * x) * w),
      __x0 * x + __y0 * y + __z0 * z);
  _w1 += w;
  _x1 += w * (__x0 + (__x0 = x));
  _y1 += w * (__y0 + (__y0 = y));
  _z1 += w * (__z0 + (__z0 = z));
  _centroidPointCartesian(__x0, __y0, __z0);
}

void _centroidLineEnd() {
  _centroidStream.point = _centroidPoint;
}

// See J. E. Brock, The Inertia Tensor for a Spherical Triangle,
// J. Applied Mechanics 42, 239 (1975).
void _centroidRingStart() {
  _centroidStream.point = _centroidRingPointFirst;
}

void _centroidRingEnd() {
  _centroidRingPoint(_lambda00, _phi00);
  _centroidStream.point = _centroidPoint;
}

void _centroidRingPointFirst(num lambda, num phi, [_]) {
  _lambda00 = lambda;
  _phi00 = phi;
  lambda *= radians;
  phi *= radians;
  _centroidStream.point = _centroidRingPoint;
  var cosPhi = cos(phi);
  __x0 = cosPhi * cos(lambda);
  __y0 = cosPhi * sin(lambda);
  __z0 = sin(phi);
  _centroidPointCartesian(__x0, __y0, __z0);
}

void _centroidRingPoint(num lambda, num phi, [_]) {
  lambda *= radians;
  phi *= radians;
  var cosPhi = cos(phi),
      x = cosPhi * cos(lambda),
      y = cosPhi * sin(lambda),
      z = sin(phi),
      cx = __y0 * z - __z0 * y,
      cy = __z0 * x - __x0 * z,
      cz = __x0 * y - __y0 * x,
      m = hypot([cx, cy, cz]),
      w = asin(m), // line weight = angle
      v = m == 0 ? m : -w / m; // area weight multiplier
  _x2.add(v * cx);
  _y2.add(v * cy);
  _z2.add(v * cz);
  _w1 += w;
  _x1 += w * (__x0 + (__x0 = x));
  _y1 += w * (__y0 + (__y0 = y));
  _z1 += w * (__z0 + (__z0 = z));
  _centroidPointCartesian(__x0, __y0, __z0);
}

GeoStream _centroidStream = GeoStream(
    point: _centroidPoint,
    lineStart: _centroidLineStart,
    lineEnd: _centroidLineEnd,
    polygonStart: () {
      _centroidStream.lineStart = _centroidRingStart;
      _centroidStream.lineEnd = _centroidRingEnd;
    },
    polygonEnd: () {
      _centroidStream.lineStart = _centroidLineStart;
      _centroidStream.lineEnd = _centroidLineEnd;
    });

/// Returns the spherical centroid of the specified GeoJSON [object].
///
/// This is the spherical equivalent of [GeoPath.centroid].
///
/// {@category Spherical math}
List<double> geoCentroid(Map object) {
  _w0 = _w1 = _x0 = _y0 = _z0 = _x1 = _y1 = _z1 = 0;
  _x2 = Adder();
  _y2 = Adder();
  _z2 = Adder();
  _centroidStream(object);

  var x = _x2.valueOf(),
      y = _y2.valueOf(),
      z = _z2.valueOf(),
      m = hypot([x, y, z]);

  // If the area-weighted ccentroid is undefined,
  // fall back to length-weighted ccentroid.
  if (m < epsilon2) {
    x = _x1;
    y = _y1;
    z = _z1;
    // If the feature has zero length,
    // fall back to arithmetic mean of point vectors.
    if (_w1 < epsilon) {
      x = _x0;
      y = _y0;
      z = _z0;
    }
    m = hypot([x, y, z]);
    // If the feature still has an undefined ccentroid, then return.
    if (m < epsilon2) return [double.nan, double.nan];
  }

  return [atan2(y, x) * degrees, asin(z / m) * degrees];
}
