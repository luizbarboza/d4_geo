import '../math.dart';
import '../raw.dart';
import 'conic.dart';
import 'equirectangular.dart';

/// The raw conic equidistant projection.
GeoRawTransform geoConicEquidistantRaw(List<double> y) {
  var y0 = y[0],
      y1 = y[1],
      cy0 = cos(y0),
      n = y0 == y1 ? sin(y0) : (cy0 - cos(y1)) / (y1 - y0),
      g = cy0 / n + y0;

  if (abs(n) < epsilon) return geoEquirectangularRaw;

  forward(List<num> p) {
    var gy = g - p[1], nx = n * p[0];
    return [gy * sin(nx), g - gy * cos(nx)];
  }

  backward(List<num> p) {
    var x = p[0], gy = g - p[1], l = atan2(x, abs(gy)) * sign(gy);
    if (gy * n < 0) l -= pi * sign(x) * sign(gy);
    return [l / n, g - sign(n) * sqrt(x * x + gy * gy)];
  }

  return GeoRawTransform(forward, backward);
}

/// The conic equidistant projection.
///
/// See also [GeoConicProjection.parallels].
GeoConicProjection geoConicEquidistant() =>
    GeoConicProjection(geoConicEquidistantRaw)
      ..scale = 131.154
      ..center = [0, 13.9389];
