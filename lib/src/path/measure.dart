import '../adder.dart';
import '../identity.dart';
import '../math.dart';
import '../noop.dart';
import '../stream.dart';

var _lengthSum = Adder();
bool _lengthRing = false;
late num _x00, _y00, _x0, _y0;

GeoStream _measureStream = GeoStream(lineStart: () {
  _measureStream.point = _lengthPointFirst;
}, lineEnd: () {
  if (_lengthRing) _lengthPoint(_x00, _y00);
  _measureStream.point = noop;
}, polygonStart: () {
  _lengthRing = true;
}, polygonEnd: () {
  _lengthRing = false;
});

void _lengthPointFirst(num x, num y, [_]) {
  _measureStream.point = _lengthPoint;
  _x00 = _x0 = x;
  _y00 = _y0 = y;
}

void _lengthPoint(num x, num y, [_]) {
  _x0 -= x;
  _y0 -= y;
  _lengthSum.add(sqrt(_x0 * _x0 + _y0 * _y0));
  _x0 = x;
  _y0 = y;
}

double measure(Map object, [GeoStream Function(GeoStream)? transform]) {
  (transform ?? identity)(_measureStream)(object);
  var length = _lengthSum.valueOf();
  _lengthSum = Adder();
  return length;
}
