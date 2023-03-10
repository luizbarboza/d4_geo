import '../math.dart';
import '../raw.dart';
import 'projection.dart';

final _a1 = 1.340264,
    _a2 = -0.081106,
    _a3 = 0.000893,
    _a4 = 0.003796,
    _m = sqrt(3) / 2,
    _iterations = 12;

List<double> _forward(List<num> p) {
  var l = asin(_m * sin(p[1])), l2 = l * l, l6 = l2 * l2 * l2;
  return [
    p[0] * cos(l) / (_m * (_a1 + 3 * _a2 * l2 + l6 * (7 * _a3 + 9 * _a4 * l2))),
    l * (_a1 + _a2 * l2 + l6 * (_a3 + _a4 * l2))
  ];
}

List<double> _backward(List<num> p) {
  num y = p[1], l = y, l2 = l * l, l6 = l2 * l2 * l2, delta, fy, fpy;
  for (var i = 0; i < _iterations; ++i) {
    fy = l * (_a1 + _a2 * l2 + l6 * (_a3 + _a4 * l2)) - y;
    fpy = _a1 + 3 * _a2 * l2 + l6 * (7 * _a3 + 9 * _a4 * l2);
    l -= delta = fy / fpy;
    l2 = l * l;
    l6 = l2 * l2 * l2;
    if (abs(delta) < epsilon2) break;
  }
  return [
    _m * p[0] * (_a1 + 3 * _a2 * l2 + l6 * (7 * _a3 + 9 * _a4 * l2)) / cos(l),
    asin(sin(l) / _m)
  ];
}

/// The raw Equal Earth projection, by Bojan Šavrič et al., 2018.
const geoEqualEarthRaw = GeoRawTransform(_forward, _backward);

/// The Equal Earth projection, by Bojan Šavrič et al., 2018.
GeoProjection geoEqualEarth() =>
    GeoProjection(geoEqualEarthRaw)..scale = 177.158;
