import '../identity.dart';
import '../math.dart';
import '../stream.dart';

// TODO Enforce positive area for exterior, negative area for interior?

double _x0 = 0,
    _y0 = 0,
    _z0 = 0,
    _x1 = 0,
    _y1 = 0,
    _z1 = 0,
    _x2 = 0,
    _y2 = 0,
    _z2 = 0;
late num _x00, _y00, __x0, __y0;

GeoStream _centroidStream = GeoStream(
    point: _centroidPoint,
    lineStart: _centroidLineStart,
    lineEnd: _centroidLineEnd,
    polygonStart: () {
      _centroidStream.lineStart = _centroidRingStart;
      _centroidStream.lineEnd = _centroidRingEnd;
    },
    polygonEnd: () {
      _centroidStream.point = _centroidPoint;
      _centroidStream.lineStart = _centroidLineStart;
      _centroidStream.lineEnd = _centroidLineEnd;
    });

void _centroidPoint(List<num> p) {
  _x0 += p[0];
  _y0 += p[1];
  ++_z0;
}

void _centroidLineStart() {
  _centroidStream.point = _centroidPointFirstLine;
}

void _centroidPointFirstLine(List<num> p) {
  _centroidStream.point = _centroidPointLine;
  _centroidPoint([__x0 = p[0], __y0 = p[1]]);
}

void _centroidPointLine(List<num> p) {
  var x = p[0],
      y = p[1],
      dx = x - __x0,
      dy = y - __y0,
      z = sqrt(dx * dx + dy * dy);
  _x1 += z * (__x0 + x) / 2;
  _y1 += z * (__y0 + y) / 2;
  _z1 += z;
  _centroidPoint([__x0 = x, __y0 = y]);
}

void _centroidLineEnd() {
  _centroidStream.point = _centroidPoint;
}

void _centroidRingStart() {
  _centroidStream.point = _centroidPointFirstRing;
}

void _centroidRingEnd() {
  _centroidPointRing([_x00, _y00]);
}

void _centroidPointFirstRing(List<num> p) {
  _centroidStream.point = _centroidPointRing;
  _centroidPoint([_x00 = __x0 = p[0], _y00 = __y0 = p[1]]);
}

void _centroidPointRing(List<num> p) {
  num x = p[0],
      y = p[1],
      dx = x - __x0,
      dy = y - __y0,
      z = sqrt(dx * dx + dy * dy);

  _x1 += z * (__x0 + x) / 2;
  _y1 += z * (__y0 + y) / 2;
  _z1 += z;

  z = __y0 * x - __x0 * y;
  _x2 += z * (__x0 + x);
  _y2 += z * (__y0 + y);
  _z2 += z * 3;
  _centroidPoint([__x0 = x, __y0 = y]);
}

List<double> centroid(Map object, [GeoStream Function(GeoStream)? transform]) {
  (transform ?? identity)(_centroidStream)(object);
  var centroid = _z2 != 0
      ? [_x2 / _z2, _y2 / _z2]
      : _z1 != 0
          ? [_x1 / _z1, _y1 / _z1]
          : _z0 != 0
              ? [_x0 / _z0, _y0 / _z0]
              : [double.nan, double.nan];
  _x0 = _y0 = _z0 = _x1 = _y1 = _z1 = _x2 = _y2 = _z2 = 0;
  return centroid;
}
