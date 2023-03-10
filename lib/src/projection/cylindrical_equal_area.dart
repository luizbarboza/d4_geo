import '../math.dart';
import '../raw.dart';

GeoRawTransform cylindricalEqualAreaRaw(double phi0) {
  var cosPhi0 = cos(phi0);

  forward(List<num> p) => [p[0] * cosPhi0, sin(p[1]) / cosPhi0];

  backward(List<num> p) => [p[0] / cosPhi0, asin(p[1] * cosPhi0)];

  return GeoRawTransform(forward, backward);
}
