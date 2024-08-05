import '../math.dart';

List<num> Function(num, num, [num?]) azimuthalRaw(
        double Function(double) scale) =>
    (x, y, [_]) {
      var cx = cos(x), cy = cos(y), k = scale(cx * cy);
      if (k == double.infinity) return [2, 0];
      return [k * cy * sin(x), k * sin(y)];
    };

List<num> Function(num, num, [num?]) azimuthalInvert(
        double Function(double) angle) =>
    (x, y, [_]) {
      var z = sqrt(x * x + y * y), c = angle(z), sc = sin(c), cc = cos(c);
      return [atan2(x * sc, z * cc), asin(z == 0 ? z : y * sc / z)];
    };
