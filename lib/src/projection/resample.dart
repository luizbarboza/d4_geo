import '../cartesian.dart';
import '../math.dart';
import '../raw.dart';
import '../stream.dart';
import '../transform.dart';

double _maxDepth = 16, // maximum depth of subdivision
    _cosMinDistance = cos(30 * radians); // cos(minimum angular distance)

GeoStream Function(GeoStream) resample(
        GeoRawTransform project, double delta2) =>
    delta2 > 0 ? _resampleDelta(project, delta2) : _resampleNone(project);

GeoStream Function(GeoStream) _resampleNone(GeoRawTransform project) =>
    GeoTransform(point: (stream, p) => stream.point(project.forward(p)));

GeoStream Function(GeoStream) _resampleDelta(
    GeoRawTransform project, double delta2) {
  void resampleLineTo(
      num x0,
      num y0,
      num lambda0,
      double a0,
      double b0,
      double c0,
      num x1,
      num y1,
      num lambda1,
      double a1,
      double b1,
      double c1,
      double depth,
      GeoStream stream) {
    var dx = x1 - x0, dy = y1 - y0, d2 = dx * dx + dy * dy;
    if (d2 > 4 * delta2 && depth-- > 0) {
      var a = a0 + a1,
          b = b0 + b1,
          c = c0 + c1,
          m = sqrt(a * a + b * b + c * c),
          phi2 = asin(c /= m),
          lambda2 =
              abs(abs(c) - 1) < epsilon || abs(lambda0 - lambda1) < epsilon
                  ? (lambda0 + lambda1) / 2
                  : atan2(b, a),
          p = project.forward([lambda2, phi2]),
          x2 = p[0],
          y2 = p[1],
          dx2 = x2 - x0,
          dy2 = y2 - y0,
          dz = dy * dx2 - dx * dy2;
      if (dz * dz / d2 > delta2 // perpendicular projected distance
          ||
          abs((dx * dx2 + dy * dy2) / d2 - 0.5) >
              0.3 // midpoint close to an end
          ||
          a0 * a1 + b0 * b1 + c0 * c1 < _cosMinDistance) {
        // angular distance
        resampleLineTo(x0, y0, lambda0, a0, b0, c0, x2, y2, lambda2, a /= m,
            b /= m, c, depth, stream);
        stream.point([x2, y2]);
        resampleLineTo(x2, y2, lambda2, a, b, c, x1, y1, lambda1, a1, b1, c1,
            depth, stream);
      }
    }
  }

  return (stream) {
    late num lambda00, x00, y00;
    late double a00, b00, c00; // first point
    late num lambda0, x0, y0;
    late double a0, b0, c0; // previous point

    var resampleStream = GeoStream();

    void point(List<num> p) {
      stream.point(project.forward(p));
    }

    void linePoint(List<num> s) {
      var c = cartesian(s), p = project.forward(s);
      resampleLineTo(x0, y0, lambda0, a0, b0, c0, x0 = p[0], y0 = p[1],
          lambda0 = s[0], a0 = c[0], b0 = c[1], c0 = c[2], _maxDepth, stream);
      stream.point([x0, y0]);
    }

    void lineStart() {
      lambda0 = x0 = y0 = a0 = b0 = c0 = double.nan;
      resampleStream.point = linePoint;
      stream.lineStart();
    }

    void lineEnd() {
      resampleStream.point = point;
      stream.lineEnd();
    }

    void ringPoint(List<num> p) {
      lambda00 = p[0];
      linePoint(p);
      x00 = x0;
      y00 = y0;
      a00 = a0;
      b00 = b0;
      c00 = c0;
      resampleStream.point = linePoint;
    }

    void ringEnd() {
      resampleLineTo(x0, y0, lambda0, a0, b0, c0, x00, y00, lambda00, a00, b00,
          c00, _maxDepth, stream);
      resampleStream.lineEnd = lineEnd;
      lineEnd();
    }

    void ringStart() {
      lineStart();
      resampleStream
        ..point = ringPoint
        ..lineEnd = ringEnd;
    }

    resampleStream
      ..point = point
      ..lineStart = lineStart
      ..lineEnd = lineEnd
      ..polygonStart = () {
        stream.polygonStart();
        resampleStream.lineStart = ringStart;
      }
      ..polygonEnd = () {
        stream.polygonEnd();
        resampleStream.lineStart = lineStart;
      };

    return resampleStream;
  };
}
