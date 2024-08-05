import '../math.dart';
import '../polygon_contains.dart';
import '../stream.dart';
import 'buffer.dart';
import 'line.dart';
import 'rejoin.dart';

GeoStream Function(GeoStream) clip(
        bool Function(num, num) pointVisible,
        ClipLine Function(GeoStream) clipLine,
        void Function(List<num>?, List<num>?, int, GeoStream) interpolate,
        List<double> start) =>
    (sink) {
      var line = clipLine(sink),
          ringBuffer = Buffer(),
          ringSink = clipLine(ringBuffer),
          polygonStarted = false;
      List<List<List<num>>>? polygon;
      List<List<List<List<num>>>>? segments;
      List<List<num>>? ring;

      var clip = GeoStream();

      void point(num lambda, num phi, [_]) {
        if (pointVisible(lambda, phi)) sink.point(lambda, phi);
      }

      void pointLine(num lambda, num phi, [_]) {
        line.point(lambda, phi);
      }

      void lineStart() {
        clip.point = pointLine;
        line.lineStart();
      }

      void lineEnd() {
        clip.point = point;
        line.lineEnd();
      }

      void pointRing(num lambda, num phi, [_]) {
        ring!.add([lambda, phi]);
        ringSink.point(lambda, phi);
      }

      void ringStart() {
        ringSink.lineStart();
        ring = [];
      }

      void ringEnd() {
        pointRing(ring![0][0], ring![0][1]);
        ringSink.lineEnd();

        var clean = ringSink.clean(), ringSegments = ringBuffer.result();
        int i, n = ringSegments.length, m;
        List<List<num>> segment;
        List<num> point;

        ring!.removeLast();
        polygon!.add(ring!);
        ring = null;

        if (n == 0) return;

        // No intersections.
        if ((clean & 1) != 0) {
          segment = ringSegments[0];
          if ((m = segment.length - 1) > 0) {
            if (!polygonStarted) {
              sink.polygonStart();
              polygonStarted = true;
            }
            sink.lineStart();
            for (i = 0; i < m; ++i) {
              sink.point((point = segment[i])[0], point[1]);
            }
            sink.lineEnd();
          }
          return;
        }

        // Rejoin connected segments.
        // TODO reuse ringBuffer.rejoin()?
        if (n > 1 && (clean & 2) != 0) {
          ringSegments.add(List.from(ringSegments.removeLast())
            ..addAll(ringSegments.removeAt(0)));
        }

        segments!.add(ringSegments.where(_validSegment).toList());
      }

      clip
        ..point = point
        ..lineStart = lineStart
        //clip.test = 1;
        ..lineEnd = lineEnd
        ..polygonStart = () {
          clip
            ..point = pointRing
            ..lineStart = ringStart
            ..lineEnd = ringEnd;
          segments = [];
          polygon = [];
        }
        ..polygonEnd = () {
          clip
            ..point = point
            ..lineStart = lineStart
            ..lineEnd = lineEnd;
          var mergedSegments = segments!.expand((x) => x).toList(),
              startInside = polygonContains(polygon!, start);
          if (segments!.isNotEmpty) {
            if (!polygonStarted) {
              sink.polygonStart();
              polygonStarted = true;
            }
            rejoin(mergedSegments, _compareIntersection, startInside,
                interpolate, sink);
          } else if (startInside) {
            if (!polygonStarted) {
              sink.polygonStart();
              polygonStarted = true;
            }
            sink.lineStart();
            interpolate(null, null, 1, sink);
            sink.lineEnd();
          }
          if (polygonStarted) {
            sink.polygonEnd();
            polygonStarted = false;
          }
          segments = polygon = null;
        }
        ..sphere = () {
          sink.polygonStart();
          sink.lineStart();
          interpolate(null, null, 1, sink);
          sink.lineEnd();
          sink.polygonEnd();
        };

      return clip;
    };

bool _validSegment(List<List<num>> segment) => segment.length > 1;

int _compareIntersection(Intersection a, Intersection b) {
  var ax = a.x, bx = b.x;
  return (ax[0] < 0 ? ax[1] - halfPi - epsilon : halfPi - ax[1])
      .compareTo(bx[0] < 0 ? bx[1] - halfPi - epsilon : halfPi - bx[1]);
}
