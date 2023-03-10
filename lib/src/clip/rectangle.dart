import 'dart:math';

import '../math.dart';
import '../stream.dart';
import 'buffer.dart';
import 'line.dart';
import 'rejoin.dart';

const _clipMax = 1e9, _clipMin = -_clipMax;

// TODO Use d3-polygon’s polygonContains here for the ring check?
// TODO Eliminate duplicate buffering in clipBuffer and polygon.push?

/// Generates a clipping function which transforms a stream such that geometries
/// are bounded by a rectangle of coordinates \[\[[x0], [y0]\], \[[x1], [y1]\]\].
///
/// Typically used for post-clipping.
GeoStream Function(GeoStream) geoClipRectangle(num x0, num y0, num x1, num y1) {
  bool visible(List<num> p) {
    var x = p[0], y = p[1];
    return x0 <= x && x <= x1 && y0 <= y && y <= y1;
  }

  int corner(List<num> p, int direction) => abs(p[0] - x0) < epsilon
      ? direction > 0
          ? 0
          : 3
      : abs(p[0] - x1) < epsilon
          ? direction > 0
              ? 2
              : 1
          : abs(p[1] - y0) < epsilon
              ? direction > 0
                  ? 1
                  : 0
              : direction > 0
                  ? 3
                  : 2; // abs(p[1] - y1) < epsilon

  int comparePoint(List<num> a, List<num> b) {
    var ca = corner(a, 1), cb = corner(b, 1);
    return ca != cb
        ? ca - cb
        : ca == 0
            ? b[1].compareTo(a[1])
            : ca == 1
                ? a[0].compareTo(b[0])
                : ca == 2
                    ? a[1].compareTo(b[1])
                    : b[0].compareTo(a[0]);
  }

  void interpolate(
      List<num>? from, List<num>? to, int direction, GeoStream stream) {
    var a = 0, a1 = 0;
    if (from == null ||
        (a = corner(from, direction)) != (a1 = corner(to!, direction)) ||
        (comparePoint(from, to) < 0) ^ (direction > 0)) {
      do {
        stream.point([if (a == 0 || a == 3) x0 else x1, if (a > 1) y1 else y0]);
      } while ((a = (a + direction + 4) % 4) != a1);
    } else {
      stream.point(to);
    }
  }

  int compareIntersection(Intersection a, Intersection b) =>
      comparePoint(a.x, b.x);

  return (stream) {
    var activeStream = stream, bufferStream = Buffer();
    List<List<List<List<num>>>>? segments;
    List<List<List<num>>>? polygon;
    List<List<num>>? ring;
    late num x0_, y0_;
    late bool v0_; // first point
    late num x1_, y1_;
    late bool v1_; // previous point
    late bool first;
    late bool clean;

    var clipStream = GeoStream();

    void point(List<num> p) {
      if (visible(p)) activeStream.point(p);
    }

    int polygonInside() {
      var winding = 0;

      for (var i = 0, n = polygon!.length; i < n; ++i) {
        num a0, a1;
        for (var ring = polygon![i],
                j = 1,
                m = ring.length,
                point = ring[0],
                b0 = point[0],
                b1 = point[1];
            j < m;
            ++j) {
          a0 = b0;
          a1 = b1;
          point = ring[j];
          b0 = point[0];
          b1 = point[1];
          if (a1 <= y1) {
            if (b1 > y1 && (b0 - a0) * (y1 - a1) > (b1 - a1) * (x0 - a0)) {
              ++winding;
            }
          } else {
            if (b1 <= y1 && (b0 - a0) * (y1 - a1) < (b1 - a1) * (x0 - a0)) {
              --winding;
            }
          }
        }
      }

      return winding;
    }

    // Buffer geometry within a polygon and then clip it en masse.
    void polygonStart() {
      activeStream = bufferStream;
      segments = [];
      polygon = [];
      clean = true;
    }

    void polygonEnd() {
      var startInside = polygonInside() != 0,
          cleanInside = clean && startInside,
          mergedSegments = segments!.expand((x) => x).toList(),
          visible = mergedSegments.isNotEmpty;
      if (cleanInside || visible) {
        stream.polygonStart();
        if (cleanInside) {
          stream.lineStart();
          interpolate(null, null, 1, stream);
          stream.lineEnd();
        }
        if (visible) {
          rejoin(mergedSegments, compareIntersection, startInside, interpolate,
              stream);
        }
        stream.polygonEnd();
      }
      activeStream = stream;
      segments = null;
      polygon = null;
      ring = null;
    }

    void linePoint(List<num> p) {
      var x = p[0], y = p[1], v = visible(p);
      if (polygon != null) ring!.add([x, y]);
      if (first) {
        x0_ = x;
        y0_ = y;
        v0_ = v;
        first = false;
        if (v) {
          activeStream.lineStart();
          activeStream.point(p);
        }
      } else {
        if (v && v1_) {
          activeStream.point(p);
        } else {
          var a = [
                x1_ = max(_clipMin, min(_clipMax, x1_)),
                y1_ = max(_clipMin, min(_clipMax, y1_))
              ],
              b = [
                x = max(_clipMin, min(_clipMax, x)),
                y = max(_clipMin, min(_clipMax, y))
              ];
          if (clipLine(a, b, x0, y0, x1, y1)) {
            if (!v1_) {
              activeStream.lineStart();
              activeStream.point(a);
            }
            activeStream.point(b);
            if (!v) activeStream.lineEnd();
            clean = false;
          } else if (v) {
            activeStream.lineStart();
            activeStream.point([x, y]);
            clean = false;
          }
        }
      }
      x1_ = x;
      y1_ = y;
      v1_ = v;
    }

    void lineStart() {
      clipStream.point = linePoint;
      if (polygon != null) polygon!.add(ring = []);
      first = true;
      v1_ = false;
      x1_ = y1_ = double.nan;
    }

    // TODO rather than special-case polygons, simply handle them separately.
    // Ideally, coincident intersection points should be jittered to avoid
    // clipping issues.
    void lineEnd() {
      if (segments != null) {
        linePoint([x0_, y0_]);
        if (v0_ && v1_) bufferStream.rejoin();
        segments!.add(bufferStream.result());
      }
      clipStream.point = point;
      if (v1_) activeStream.lineEnd();
    }

    clipStream
      ..point = point
      ..lineStart = lineStart
      ..lineEnd = lineEnd
      ..polygonStart = polygonStart
      ..polygonEnd = polygonEnd;

    return clipStream;
  };
}
