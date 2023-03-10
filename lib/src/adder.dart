import 'dart:typed_data';

import 'math.dart';

class Adder {
  final Float64List _partials = Float64List(32);
  int _n = 0;

  void add(double x) {
    final p = _partials;
    var i = 0;
    for (var j = 0; j < _n && j < 32; j++) {
      final y = p[j],
          hi = x + y,
          lo = abs(x) < abs(y) ? x - (hi - y) : y - (hi - x);
      if (lo != 0) p[i++] = lo;
      x = hi;
    }
    p[i] = x;
    _n = i + 1;
  }

  double valueOf() {
    final p = _partials;
    var n = _n;
    late double x, y, lo, hi = 0;
    if (n > 0) {
      hi = p[--n];
      while (n > 0) {
        x = hi;
        y = p[--n];
        hi = x + y;
        lo = y - (hi - x);
        if (lo != 0) break;
      }
      if (n > 0 && ((lo < 0 && p[n - 1] < 0) || (lo > 0 && p[n - 1] > 0))) {
        y = lo * 2;
        x = hi + y;
        if (y == x - hi) hi = x;
      }
    }
    return hi;
  }
}
