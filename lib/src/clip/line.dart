import '../stream.dart';

bool clipLine(List<num> a, List<num> b, num x0, num y0, num x1, num y1) {
  num ax = a[0],
      ay = a[1],
      bx = b[0],
      by = b[1],
      t0 = 0,
      t1 = 1,
      dx = bx - ax,
      dy = by - ay,
      r;

  r = x0 - ax;
  if (dx == 0 && r > 0) return false;
  r /= dx;
  if (dx < 0) {
    if (r < t0) return false;
    if (r < t1) t1 = r;
  } else if (dx > 0) {
    if (r > t1) return false;
    if (r > t0) t0 = r;
  }

  r = x1 - ax;
  if (dx == 0 && r < 0) return false;
  r /= dx;
  if (dx < 0) {
    if (r > t1) return false;
    if (r > t0) t0 = r;
  } else if (dx > 0) {
    if (r < t0) return false;
    if (r < t1) t1 = r;
  }

  r = y0 - ay;
  if (dy == 0 && r > 0) return false;
  r /= dy;
  if (dy < 0) {
    if (r < t0) return false;
    if (r < t1) t1 = r;
  } else if (dy > 0) {
    if (r > t1) return false;
    if (r > t0) t0 = r;
  }

  r = y1 - ay;
  if (dy == 0 && r < 0) return false;
  r /= dy;
  if (dy < 0) {
    if (r > t1) return false;
    if (r > t0) t0 = r;
  } else if (dy > 0) {
    if (r < t0) return false;
    if (r < t1) t1 = r;
  }

  if (t0 > 0) {
    a[0] = ax + t0 * dx;
    a[1] = ay + t0 * dy;
  }
  if (t1 < 1) {
    b[0] = ax + t1 * dx;
    b[1] = ay + t1 * dy;
  }
  return true;
} // planar

class ClipLine extends GeoStream {
  late final int Function() clean;
} // spherical
