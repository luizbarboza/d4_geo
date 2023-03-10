import '../math.dart';
import '../point_equal.dart';
import '../stream.dart';

class Intersection {
  List<num> x;
  List<List<num>>? z;
  Intersection? o;
  Intersection? n;
  Intersection? p;
  bool e;
  bool v;

  Intersection(
      List<num> point, List<List<num>>? points, Intersection? other, bool entry)
      : x = point,
        z = points,
        o = other, // another intersection
        e = entry, // is an entry?
        v = false // visited
  {
    n = p = null; // next & previous
  }
}

void rejoin(
    List<List<List<num>>> segments,
    int Function(Intersection, Intersection) compareIntersection,
    bool startInside,
    void Function(List<num>, List<num>, int, GeoStream) interpolate,
    GeoStream stream) {
  var subject = <Intersection>[], clip = <Intersection>[];
  int i, n;

  for (final segment in segments) {
    if ((n = segment.length - 1) <= 0) continue;
    var p0 = segment[0], p1 = segment[n];
    Intersection x;

    if (pointEqual(p0, p1)) {
      if (p0.length == 2 && p1.length == 2) {
        stream.lineStart();
        for (i = 0; i < n; ++i) {
          stream.point(p0 = segment[i]);
        }
        stream.lineEnd();
        continue;
      }
      // handle degenerate cases by moving the point
      p1[0] += 2 * epsilon;
    }

    subject.add(x = Intersection(p0, segment, null, true));
    clip.add(x.o = Intersection(p0, null, x, false));
    subject.add(x = Intersection(p1, segment, null, false));
    clip.add(x.o = Intersection(p1, null, x, true));
  }

  if (subject.isEmpty) return;

  clip.sort(compareIntersection);
  _link(subject);
  _link(clip);

  n = clip.length;
  for (i = 0; i < n; ++i) {
    clip[i].e = startInside = !startInside;
  }

  var start = subject[0];
  List<List<num>>? points;

  while (true) {
    // Find first unvisited intersection.
    var current = start, isSubject = true;
    while (current.v) {
      if (identical((current = current.n!), start)) {
        return;
      }
    }
    points = current.z!;
    stream.lineStart();
    do {
      current.v = current.o!.v = true;
      if (current.e) {
        if (isSubject) {
          n = points!.length;
          for (i = 0; i < n; ++i) {
            stream.point(points[i]);
          }
        } else {
          interpolate(current.x, current.n!.x, 1, stream);
        }
        current = current.n!;
      } else {
        if (isSubject) {
          points = current.p!.z!;
          for (i = points.length - 1; i >= 0; --i) {
            stream.point(points[i]);
          }
        } else {
          interpolate(current.x, current.p!.x, -1, stream);
        }
        current = current.p!;
      }
      current = current.o!;
      points = current.z;
      isSubject = !isSubject;
    } while (!current.v);
    stream.lineEnd();
  }
}

void _link(List<Intersection> array) {
  int n;
  if ((n = array.length) == 0) return;
  var i = 0;
  Intersection a = array[0], b;
  while (++i < n) {
    a.n = b = array[i];
    b.p = a;
    a = b;
  }
  a.n = b = array[0];
  b.p = a;
}
