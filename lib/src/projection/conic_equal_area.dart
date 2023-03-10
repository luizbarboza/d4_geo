import '../math.dart';
import '../raw.dart';
import 'conic.dart';
import 'cylindrical_equal_area.dart';

/// The raw Albers’ equal-area conic projection.
GeoRawTransform geoConicEqualAreaRaw(List<double> y) {
  var y0 = y[0], y1 = y[1], sy0 = sin(y0), n = (sy0 + sin(y1)) / 2;

  // Are the parallels symmetrical around the Equator?
  if (abs(n) < epsilon) return cylindricalEqualAreaRaw(y0);

  var c = 1 + sy0 * (2 * n - sy0), r0 = sqrt(c) / n;

  forward(List<num> p) {
    var x = p[0], r = sqrt(c - 2 * n * sin(p[1])) / n;
    return [r * sin(x *= n), r0 - r * cos(x)];
  }

  backward(List<num> p) {
    var x = p[0], r0y = r0 - p[1], l = atan2(x, abs(r0y)) * sign(r0y);
    if (r0y * n < 0) l -= pi * sign(x) * sign(r0y);
    return [l / n, asin((c - (x * x + r0y * r0y) * n * n) / (2 * n))];
  }

  return GeoRawTransform(forward, backward);
}

/// The Albers’ equal-area conic projection.
///
/// See also [GeoConicProjection.parallels].
GeoConicProjection geoConicEqualArea() =>
    GeoConicProjection(geoConicEqualAreaRaw)
      ..scale = 155.424
      ..center = [0, 33.6442];
