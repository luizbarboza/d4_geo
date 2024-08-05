import '../math.dart';
import 'raw.dart';
import 'conic.dart';
import 'equirectangular.dart';

/// The raw conic equidistant projection.
///
/// {@category Projections}
/// {@category Conic projections}
GeoRawProjection geoConicEquidistantRaw([List? y]) {
  var y0 = y![0],
      y1 = y[1],
      cy0 = cos(y0),
      n = y0 == y1 ? sin(y0) : (cy0 - cos(y1)) / (y1 - y0),
      g = cy0 / n + y0;

  if (abs(n) < epsilon) return geoEquirectangularRaw;

  project(num x, num y, [_]) {
    var gy = g - y, nx = n * x;
    return [gy * sin(nx), g - gy * cos(nx)];
  }

  invert(num x, num y, [_]) {
    var gy = g - y, l = atan2(x, abs(gy)) * sign(gy);
    if (gy * n < 0) l -= pi * sign(x) * sign(gy);
    return [l / n, g - sign(n) * sqrt(x * x + gy * gy)];
  }

  return GeoRawProjection(project, invert);
}

/// The conic equidistant projection.
///
/// See also [GeoConicProjection.parallels].
///
/// {@category Projections}
/// {@category Conic projections}
GeoConicProjection geoConicEquidistant() =>
    GeoConicProjection(geoConicEquidistantRaw)
      ..scale = 131.154
      ..center = [0, 13.9389];
