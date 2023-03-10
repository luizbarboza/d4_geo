import '../math.dart';
import '../stream.dart';
import 'clip.dart';
import 'line.dart';

/// A clipping function which transforms a stream such that geometries (lines or
/// polygons) that cross the antimeridian line are cut in two, one on each side.
///
/// Typically used for pre-clipping.
final geoClipAntimeridian = clip((_) => true, _clipAntimeridianLine,
    _clipAntimeridianInterpolate, [-pi, -halfPi]);

// Takes a line and cuts into visible segments. Return values: 0 - there were
// intersections or the line was empty; 1 - no intersections; 2 - there were
// intersections, and the first and last segments should be rejoined.

/// A clipping function which transforms a stream such that geometries (lines or
/// polygons) that cross the antimeridian line are cut in two, one on each side.
///
/// Typically used for pre-clipping.
ClipLine _clipAntimeridianLine(GeoStream stream) {
  num lambda0 = double.nan, phi0 = double.nan;
  var sign0 = double.nan;
  var clean = 0; // no intersections

  var line = ClipLine()
    ..lineStart = () {
      stream.lineStart();
      clean = 1;
    }
    ..point = (p) {
      var lambda1 = p[0],
          phi1 = p[1],
          sign1 = lambda1 > 0 ? pi : -pi,
          delta = abs(lambda1 - lambda0);
      if (abs(delta - pi) < epsilon) {
        // line crosses a pole
        stream
            .point([lambda0, phi0 = (phi0 + phi1) / 2 > 0 ? halfPi : -halfPi]);
        stream.point([sign0, phi0]);
        stream.lineEnd();
        stream.lineStart();
        stream.point([sign1, phi0]);
        stream.point([lambda1, phi0]);
        clean = 0;
      } else if (sign0 != sign1 && delta >= pi) {
        // line crosses antimeridian
        if (abs(lambda0 - sign0) < epsilon) {
          lambda0 -= sign0 * epsilon;
        } // handle degeneracies
        if (abs(lambda1 - sign1) < epsilon) lambda1 -= sign1 * epsilon;
        phi0 = _clipAntimeridianIntersect(lambda0, phi0, lambda1, phi1);
        stream.point([sign0, phi0]);
        stream.lineEnd();
        stream.lineStart();
        stream.point([sign1, phi0]);
        clean = 0;
      }
      stream.point([lambda0 = lambda1, phi0 = phi1]);
      sign0 = sign1;
    }
    ..lineEnd = () {
      stream.lineEnd();
      lambda0 = phi0 = double.nan;
    }
    ..clean =
        () => 2 - clean; // if intersections, rejoin first and last segments

  return line;
}

double _clipAntimeridianIntersect(
    num lambda0, num phi0, num lambda1, num phi1) {
  double cosPhi0, cosPhi1, sinLambda0Lambda1 = sin(lambda0 - lambda1);
  return abs(sinLambda0Lambda1) > epsilon
      ? atan((sin(phi0) * (cosPhi1 = cos(phi1)) * sin(lambda1) -
              sin(phi1) * (cosPhi0 = cos(phi0)) * sin(lambda0)) /
          (cosPhi0 * cosPhi1 * sinLambda0Lambda1))
      : (phi0 + phi1) / 2;
}

void _clipAntimeridianInterpolate(
    List<num>? from, List<num>? to, int direction, GeoStream stream) {
  double phi;
  if (from == null) {
    phi = direction * halfPi;
    stream.point([-pi, phi]);
    stream.point([0, phi]);
    stream.point([pi, phi]);
    stream.point([pi, 0]);
    stream.point([pi, -phi]);
    stream.point([0, -phi]);
    stream.point([-pi, -phi]);
    stream.point([-pi, 0]);
    stream.point([-pi, phi]);
  } else if (abs(from[0] - to![0]) > epsilon) {
    var lambda = from[0] < to[0] ? pi : -pi;
    phi = direction * lambda / 2;
    stream.point([-lambda, phi]);
    stream.point([0, phi]);
    stream.point([lambda, phi]);
  } else {
    stream.point(to);
  }
}
