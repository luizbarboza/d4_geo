import '../math.dart';
import 'raw.dart';
import 'conic.dart';
import 'cylindrical_equal_area.dart';

/// The raw Albers’ equal-area conic projection.
///
/// {@category Projections}
/// {@category Conic projections}
GeoRawProjection geoConicEqualAreaRaw([List? y]) {
  var sy0 = sin(y![0]), n = (sy0 + sin(y[1])) / 2;

  // Are the parallels symmetrical around the Equator?
  if (abs(n) < epsilon) return cylindricalEqualAreaRaw(y[0].toDouble());

  var c = 1 + sy0 * (2 * n - sy0), r0 = sqrt(c) / n;

  project(num x, num y, [_]) {
    var r = sqrt(c - 2 * n * sin(y)) / n;
    return [r * sin(x *= n), r0 - r * cos(x)];
  }

  invert(num x, num y, [_]) {
    var r0y = r0 - y, l = atan2(x, abs(r0y)) * sign(r0y);
    if (r0y * n < 0) l -= pi * sign(x) * sign(r0y);
    return [l / n, asin((c - (x * x + r0y * r0y) * n * n) / (2 * n))];
  }

  return GeoRawProjection(project, invert);
}

/// The Albers’ equal-area conic projection.
///
/// See also [GeoConicProjection.parallels].
///
/// {@category Projections}
/// {@category Conic projections}
GeoConicProjection geoConicEqualArea() =>
    GeoConicProjection(geoConicEqualAreaRaw)
      ..scale = 155.424
      ..center = [0, 33.6442];
