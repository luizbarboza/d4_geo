import '../math.dart';
import 'raw.dart';

GeoRawProjection cylindricalEqualAreaRaw(double phi0) {
  var cosPhi0 = cos(phi0);

  forward(num lambda, num phi, [_]) => [lambda * cosPhi0, sin(phi) / cosPhi0];

  invert(num x, num y, [_]) => [x / cosPhi0, asin(y * cosPhi0)];

  return GeoRawProjection(forward, invert);
}
