import '../identity.dart';
import '../stream.dart';

late num _x0, _y0, _x1, _y1;

var _boundsStream = GeoStream(point: _boundsPoint);

void _boundsPoint(List<num> p) {
  var x = p[0], y = p[1];
  if (x < _x0) _x0 = x;
  if (x > _x1) _x1 = x;
  if (y < _y0) _y0 = y;
  if (y > _y1) _y1 = y;
}

List<List<num>> bounds(Map object,
    [GeoStream Function(GeoStream) transform = identity]) {
  _x1 = _y1 = -(_y0 = _x0 = double.infinity);
  transform(_boundsStream)(object);
  return [
    [_x0, _y0],
    [_x1, _y1]
  ];
}
