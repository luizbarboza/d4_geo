import '../cartesian.dart';
import '../circle.dart';
import '../math.dart';
import '../point_equal.dart';
import '../projection/projection.dart';
import '../stream.dart';
import 'clip.dart';
import 'line.dart';

/// Generates a clipping function which transforms a stream such that geometries
/// are bounded by a small circle of radius [angle] around the
/// [GeoProjection.center].
///
/// Typically used for pre-clipping.
GeoStream Function(GeoStream) geoClipCircle(double angle) {
  final cr = cos(angle),
      delta = 6 * radians,
      smallRadius = cr > 0,
      notHemisphere = abs(cr) > epsilon; // TODO optimise for this common case

  void interpolate(
      List<num>? from, List<num>? to, int direction, GeoStream stream) {
    circleStream(stream, angle, delta, direction, from, to);
  }

  bool visible(List<num> p) => cos(p[0]) * cos(p[1]) > cr;

  // Intersects the great circle between a and b with the clip circle.
  List<List<num>>? intersect(List<num> a, List<num> b, bool two) {
    var pa = cartesian(a), pb = cartesian(b);

    // We have two planes, n1.p = d1 and n2.p = d2.
    // Find intersection line p(t) = c1 n1 + c2 n2 + t (n1 ⨯ n2).
    var n1 = [1.0, 0.0, 0.0], // normal
        n2 = cartesianCross(pa, pb);
    var n2n2 = cartesianDot(n2, n2),
        n1n2 = n2[0], // cartesianDot(n1, n2),
        determinant = n2n2 - n1n2 * n1n2;

    // Two polar points.
    if (determinant == 0) return !two ? [a] : null;

    var c1 = cr * n2n2 / determinant,
        c2 = -cr * n1n2 / determinant,
        n1xn2 = cartesianCross(n1, n2),
        A = cartesianScale(n1, c1),
        B = cartesianScale(n2, c2);
    cartesianAddInPlace(A, B);

    // Solve |p(t)|^2 = 1.
    var u = n1xn2,
        w = cartesianDot(A, u),
        uu = cartesianDot(u, u),
        t2 = w * w - uu * (cartesianDot(A, A) - 1);

    if (t2 < 0) return null;

    var t = sqrt(t2), q = cartesianScale(u, (-w - t) / uu);
    cartesianAddInPlace(q, A);
    q = spherical(q);

    if (!two) return [q];

    // Two intersection points.
    num lambda0 = a[0], lambda1 = b[0], phi0 = a[1], phi1 = b[1], z;

    if (lambda1 < lambda0) {
      z = lambda0;
      lambda0 = lambda1;
      lambda1 = z;
    }

    var delta = lambda1 - lambda0,
        polar = abs(delta - pi) < epsilon,
        meridian = polar || delta < epsilon;

    if (!polar && phi1 < phi0) {
      z = phi0;
      phi0 = phi1;
      phi1 = z;
    }

    // Check that the first point is between a and b.
    if (meridian
        ? polar
            ? (phi0 + phi1 > 0) ^
                (q[1] < (abs(q[0] - lambda0) < epsilon ? phi0 : phi1))
            : phi0 <= q[1] && q[1] <= phi1
        : (delta > pi) ^ (lambda0 <= q[0] && q[0] <= lambda1)) {
      var q1 = cartesianScale(u, (-w + t) / uu);
      cartesianAddInPlace(q1, A);
      return [q, spherical(q1)];
    }
    return null;
  }

  // Generates a 4-bit vector representing the location of a point relative to
  // the small circle's bounding box.
  int code(num lambda, num phi) {
    var r = smallRadius ? angle : pi - angle, code = 0;
    if (lambda < -r) {
      code |= 1;
    } else if (lambda > r) {
      code |= 2;
    } // right
    if (phi < -r) {
      code |= 4;
    } else if (phi > r) {
      code |= 8;
    } // above
    return code;
  }

  // Takes a line and cuts into visible segments. Return values used for polygon
  // clipping: 0 - there were intersections or the line was empty; 1 - no
  // intersections 2 - there were intersections, and the first and last segments
  // should be rejoined.
  ClipLine clipLine(GeoStream stream) {
    List<num>? point0; // previous point
    late int c0; // code for previous point
    late bool v0, // visibility of previous point
        v00; // visibility of first point
    late int clean; // no intersections

    var line = ClipLine()
      ..lineStart = () {
        v00 = v0 = false;
        clean = 1;
      }
      ..point = (p) {
        var lambda = p[0], phi = p[1], point1 = [lambda, phi];
        List<num>? point2;
        var v = visible(p),
            c = smallRadius
                ? v
                    ? 0
                    : code(lambda, phi)
                : v
                    ? code(lambda + (lambda < 0 ? pi : -pi), phi)
                    : 0;
        if (point0 == null && (v00 = v0 = v)) stream.lineStart();
        if (v != v0) {
          var i = intersect(point0!, point1, false);
          point2 = i != null ? i[0] : null;
          if (point2 == null ||
              pointEqual(point0!, point2) ||
              pointEqual(point1, point2)) point1.add(1);
        }
        if (v != v0) {
          clean = 0;
          if (v) {
            // outside going in
            stream.lineStart();
            point2 = intersect(point1, point0!, false)![0];
            stream.point(point2);
          } else {
            // inside going out
            point2 = intersect(point0!, point1, false)![0];
            stream.point([point2[0], point2[1], 2]);
            stream.lineEnd();
          }
          point0 = point2;
        } else if (notHemisphere && point0 != null && smallRadius ^ v) {
          List<List<num>>? t;
          // If the codes for two points are different, or are both zero,
          // and there this segment intersects with the small circle.
          if ((c & c0) != 0 && (t = intersect(point1, point0!, true)) != null) {
            clean = 0;
            if (smallRadius) {
              stream.lineStart();
              stream.point(t![0]);
              stream.point(t[1]);
              stream.lineEnd();
            } else {
              stream.point(t![1]);
              stream.lineEnd();
              stream.lineStart();
              stream.point([t[0][0], t[0][1], 3]);
            }
          }
        }
        if (v && (point0 == null || !pointEqual(point0!, point1))) {
          stream.point(point1);
        }
        point0 = point1;
        v0 = v;
        c0 = c;
      }
      ..lineEnd = () {
        if (v0) stream.lineEnd();
        point0 = null;
      }
      // Rejoin first and last segments if there were intersections
      // and the first and last points were visible.
      ..clean = () => clean | ((v00 && v0 ? 1 : 0) << 1);

    return line;
  }

  return clip(visible, clipLine, interpolate,
      smallRadius ? [0, -angle] : [-pi, angle - pi]);
}
