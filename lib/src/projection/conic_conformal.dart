import '../math.dart';
import '../raw.dart';
import 'conic.dart';
import 'mercator.dart';

double _tany(num y) => tan((halfPi + y) / 2);

/// The raw conic conformal projection.
GeoRawTransform geoConicConformalRaw(List<double> y) {
  var y0 = y[0],
      y1 = y[1],
      cy0 = cos(y0),
      n = y0 == y1 ? sin(y0) : log(cy0 / cos(y1)) / log(_tany(y1) / _tany(y0)),
      f = cy0 * pow(_tany(y0), n) / n;

  if (n == 0) return geoMercatorRaw;

  forward(List<num> p) {
    var x = p[0], y = p[1];
    if (f > 0) {
      if (y < -halfPi + epsilon) y = -halfPi + epsilon;
    } else {
      if (y > halfPi - epsilon) y = halfPi - epsilon;
    }
    var r = f / pow(_tany(y), n);
    return [r * sin(n * x), f - r * cos(n * x)];
  }

  backward(List<num> p) {
    var x = p[0],
        fy = f - p[1],
        r = sign(n) * sqrt(x * x + fy * fy),
        l = atan2(x, abs(fy)) * sign(fy);
    if (fy * n < 0) l -= pi * sign(x) * sign(fy);
    return [l / n, 2 * atan(pow(f / r, 1 / n)) - halfPi];
  }

  return GeoRawTransform(forward, backward);
}

/// The conic conformal projection.
///
/// The parallels default to \[30°, 30°\] resulting in flat top. See also
/// [GeoConicProjection.parallels].
GeoConicProjection geoConicConformal() =>
    GeoConicProjection(geoConicConformalRaw)
      ..scale = 109.5
      ..parallels = [30, 30];
