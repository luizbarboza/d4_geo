import '../adder.dart';
import '../identity.dart';
import '../math.dart';
import '../noop.dart';
import '../stream.dart';

var _areaSum = Adder(), _areaRingSum = Adder();
late num _x00, _y00, _x0, _y0;

GeoStream _stream = GeoStream(
  polygonStart: () {
    _stream.lineStart = _areaRingStart;
    _stream.lineEnd = _areaRingEnd;
  },
  polygonEnd: () {
    _stream.lineStart = _stream.lineEnd = _stream.point = noop;
    _areaSum.add(abs(_areaRingSum.valueOf()).toDouble());
    _areaRingSum = Adder();
  },
);

void _areaRingStart() {
  _stream.point = _areaPointFirst;
}

void _areaPointFirst(num x, num y, [_]) {
  _stream.point = _areaPoint;
  _x00 = _x0 = x;
  _y00 = _y0 = y;
}

void _areaPoint(num x, num y, [_]) {
  _areaRingSum.add((_y0 * x - _x0 * y).toDouble());
  _x0 = x;
  _y0 = y;
}

void _areaRingEnd() {
  _areaPoint(_x00, _y00);
}

double area(Map object, [GeoStream Function(GeoStream) transform = identity]) {
  transform(_stream)(object);
  var area = _areaSum.valueOf() / 2;
  _areaSum = Adder();
  return area;
}
