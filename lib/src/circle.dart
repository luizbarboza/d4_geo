import 'cartesian.dart';
import 'math.dart';
import 'rotation.dart';
import 'stream.dart';

void circleStream(GeoStream stream, double radius, double delta, int direction,
    [List<num>? t0, List<num>? t1]) {
  if (delta == 0) return;
  var cosRadius = cos(radius),
      sinRadius = sin(radius),
      step = direction * delta;
  double? u0, u1;
  if (t0 == null) {
    u0 = radius + direction * tau;
    u1 = radius - step / 2;
  } else {
    u0 = circleRadius(cosRadius, t0);
    u1 = circleRadius(cosRadius, t1!);
    if (direction > 0 ? u0 < u1 : u0 > u1) u0 += direction * tau;
  }
  List<double> point;
  for (var t = u0; direction > 0 ? t > u1 : t < u1; t -= step) {
    point = spherical([cosRadius, -sinRadius * cos(t), -sinRadius * sin(t)]);
    stream.point(point);
  }
}

// Returns the signed angle of a cartesian point relative to [cosRadius, 0, 0].
double circleRadius(double cosRadius, List<num> point) {
  point = cartesian(point);
  point[0] -= cosRadius;
  cartesianNormalizeInPlace(point);
  var radius = acos(-point[1]);
  return ((-point[2] < 0 ? -radius : radius) + tau - epsilon) % tau;
}

/// A geometry geographic generator for creating circles.
class GeoCircle {
  /// The circle center point in degrees.
  ///
  /// The center must be specified as \[*longitude*, *latitude*\]. Defaults to
  /// \[0, 0\]
  List<double> center;

  /// The circle radius angle in degrees.
  ///
  /// Defaults to 90.
  double radius;

  /// The circle precision angle in degrees.
  ///
  /// Defaults to 6. Small circles do not follow great arcs and thus the
  /// generated polygon is only an approximation. Specifying a smaller precision
  /// angle improves the accuracy of the approximate polygon, but also increase
  /// the cost to generate and render it.
  double precision;
  late GeoStream _stream;
  List<List<num>>? _ring;
  List<num> Function(List<num>)? _rotate;

  /// Creates a new circle generator.
  GeoCircle(
      {this.center = const [0, 0], this.radius = 90, this.precision = 6}) {
    _stream = GeoStream(point: _point);
  }

  void _point(List<num> p) {
    _ring!.add(p = _rotate!(p));
    p[0] *= degrees;
    p[1] *= degrees;
  }

  /// Returns a new GeoJSON geometry object of type “Polygon” approximating a
  /// circle on the surface of a sphere, with the current [center], [radius] and
  /// [precision].
  Map call() {
    _ring = [];
    _rotate =
        rotateRadians(-center[0] * radians, -center[1] * radians, 0).backward!;
    circleStream(_stream, radius * radians, precision * radians, 1);
    var m = {
      "type": "Polygon",
      "coordinates": [_ring!]
    };
    _ring = _rotate = null;
    return m;
  }
}
