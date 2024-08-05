import 'compose.dart';
import 'math.dart';
import 'projection/projection.dart';

List<num> _identityPoint(num lambda, num phi, [_]) {
  if (abs(lambda) > pi) lambda -= round(lambda / tau) * tau;
  return [lambda, phi];
}

const _rotationIdentity = (_identityPoint, _identityPoint);

MaybeBijective rotateRadians(
        double deltaLambda, double deltaPhi, double deltaGamma) =>
    (deltaLambda %= tau) != 0
        ? deltaPhi != 0 || deltaGamma != 0
            ? compose(_rotationLambda(deltaLambda),
                _rotationPhiGamma(deltaPhi, deltaGamma))
            : _rotationLambda(deltaLambda)
        : deltaPhi != 0 || deltaGamma != 0
            ? _rotationPhiGamma(deltaPhi, deltaGamma)
            : _rotationIdentity;

List<num> Function(num, num, [num?]) _forwardRotationLambda(
        double deltaLambda) =>
    (lambda, phi, [_]) {
      lambda += deltaLambda;
      if (abs(lambda) > pi) lambda -= round(lambda / tau) * tau;
      return [lambda, phi];
    };

MaybeBijective _rotationLambda(double deltaLambda) =>
    (_forwardRotationLambda(deltaLambda), _forwardRotationLambda(-deltaLambda));

MaybeBijective _rotationPhiGamma(double deltaPhi, deltaGamma) {
  final cosDeltaPhi = cos(deltaPhi),
      sinDeltaPhi = sin(deltaPhi),
      cosDeltaGamma = cos(deltaGamma),
      sinDeltaGamma = sin(deltaGamma);

  return (
    (lambda, phi, [_]) {
      var cosPhi = cos(phi),
          x = cos(lambda) * cosPhi,
          y = sin(lambda) * cosPhi,
          z = sin(phi),
          k = z * cosDeltaPhi + x * sinDeltaPhi;
      return [
        atan2(y * cosDeltaGamma - k * sinDeltaGamma,
            x * cosDeltaPhi - z * sinDeltaPhi),
        asin(k * cosDeltaGamma + y * sinDeltaGamma)
      ];
    },
    (lambda, phi, [_]) {
      var cosPhi = cos(phi),
          x = cos(lambda) * cosPhi,
          y = sin(lambda) * cosPhi,
          z = sin(phi),
          k = z * cosDeltaGamma - y * sinDeltaGamma;
      return [
        atan2(y * cosDeltaGamma + z * sinDeltaGamma,
            x * cosDeltaPhi + k * sinDeltaPhi),
        asin(k * cosDeltaPhi - x * sinDeltaPhi)
      ];
    }
  );
}

/// A raw transform that represents a rotation about
/// [each spherical axis](https://observablehq.com/@d3/three-axis-rotation).
///
/// {@category Spherical math}
class GeoRotation {
  MaybeBijective rotate;

  /// Returns a rotation raw transform for the given [angles].
  ///
  /// [angles] must be a two- or three-element array of numbers \[*lambda*, *phi*,
  /// *gamma*\] specifying the rotation angles in degrees about
  /// [each spherical axis](https://observablehq.com/@d3/three-axis-rotation).
  /// (These correspond to
  /// [yaw, pitch and roll](https://en.wikipedia.org/wiki/Aircraft_principal_axes).)
  /// If the rotation angle *gamma* is omitted, it defaults to 0. See also
  /// [GeoProjection.rotate].
  GeoRotation(List<double> angles)
      : rotate = rotateRadians(angles[0] * radians, angles[1] * radians,
            angles.length > 2 ? angles[2] * radians : 0);

  /// Returns a new list \[*longitude*, *latitude*\] in degrees representing the
  /// rotated point of the given [point]. The point must be specified as a
  /// two-element list \[*longitude*, *latitude*\] in degrees.
  List<num> call(List<num> point) {
    point = rotate.$1(point[0] * radians, point[1] * radians);
    point[0] *= degrees;
    point[1] *= degrees;
    return point;
  }

  /// Returns a new list \[*longitude*, *latitude*\] in degrees representing the
  /// point of the given rotated [point]; the inverse of [call]. The point must
  /// be specified as a two-element list \[*longitude*, *latitude*\] in degrees.
  List<num>? invert(List<num> point) {
    final coord = rotate.$2(point[0] * radians, point[1] * radians);
    return coord != null ? [coord[0] * degrees, coord[1] * degrees] : null;
  }
}
