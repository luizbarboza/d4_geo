import '../adder.dart';
import '../identity.dart';
import '../math.dart';
import '../noop.dart';
import '../stream.dart';

var _areaSum = Adder(), _areaRingSum = Adder();
late List<num> _p00, _p0;

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

void _areaPointFirst(List<num> p) {
  _stream.point = _areaPoint;
  _p00 = _p0 = p;
}

void _areaPoint(List<num> p) {
  _areaRingSum.add((_p0[1] * p[0] - _p0[0] * p[1]).toDouble());
  _p0 = p;
}

void _areaRingEnd() {
  _areaPoint(_p00);
}

double area(Map object, [GeoStream Function(GeoStream) transform = identity]) {
  transform(_stream)(object);
  var area = _areaSum.valueOf() / 2;
  _areaSum = Adder();
  return area;
}
