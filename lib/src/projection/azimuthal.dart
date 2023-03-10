import '../math.dart';

List<num> Function(List<num>) azimuthalForward(double Function(double) scale) =>
    (p) {
      var x = p[0], y = p[1], cx = cos(x), cy = cos(y), k = scale(cx * cy);
      if (k == double.infinity) return [2, 0];
      return [k * cy * sin(x), k * sin(y)];
    };

List<num> Function(List<num>) azimuthalBackward(
        double Function(double) angle) =>
    (p) {
      var x = p[0],
          y = p[1],
          z = sqrt(x * x + y * y),
          c = angle(z),
          sc = sin(c),
          cc = cos(c);
      return [atan2(x * sc, z * cc), asin(z == 0 ? z : y * sc / z)];
    };
