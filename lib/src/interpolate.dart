import 'math.dart';

/// Returns an interpolator function given two points [a] and [b].
///
/// Each point must be specified as a two-element array \[*longitude*,
/// *latitude*\] in degrees. The returned interpolator function takes a single
/// argument *t*, where *t* is a number ranging from 0 to 1; a value of 0
/// returns the point [a], while a value of 1 returns the point [b].
/// Intermediate values interpolate from [a] to [b] along the great arc that
/// passes through both [a] and [b]. If [a] and [b] are antipodes, an arbitrary
/// great arc is chosen.
///
/// {@category Spherical math}
List<double> Function(double) geoInterpolate(List<double> a, List<double> b) {
  var x0 = a[0] * radians,
      y0 = a[1] * radians,
      x1 = b[0] * radians,
      y1 = b[1] * radians,
      cy0 = cos(y0),
      sy0 = sin(y0),
      cy1 = cos(y1),
      sy1 = sin(y1),
      kx0 = cy0 * cos(x0),
      ky0 = cy0 * sin(x0),
      kx1 = cy1 * cos(x1),
      ky1 = cy1 * sin(x1),
      d = 2 * asin(sqrt(haversin(y1 - y0) + cy0 * cy1 * haversin(x1 - x0))),
      k = sin(d);

  return d != 0
      ? (t) {
          var B = sin(t *= d) / k,
              A = sin(d - t) / k,
              x = A * kx0 + B * kx1,
              y = A * ky0 + B * ky1,
              z = A * sy0 + B * sy1;
          return [
            atan2(y, x) * degrees,
            atan2(z, sqrt(x * x + y * y)) * degrees
          ];
        }
      : (t) => [x0 * degrees, y0 * degrees];
}
