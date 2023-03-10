import 'compose.dart';
import 'math.dart';
import 'projection/projection.dart';
import 'raw.dart';

List<num> _identityPoint(List<num> p) {
  var lambda = p[0];
  if (abs(lambda) > pi) lambda -= round(lambda / tau) * tau;
  return [lambda, p[1]];
}

const _rotationIdentity = GeoRawTransform(_identityPoint, _identityPoint);

GeoRawTransform rotateRadians(
        double deltaLambda, double deltaPhi, double deltaGamma) =>
    (deltaLambda %= tau) != 0
        ? deltaPhi != 0 || deltaGamma != 0
            ? compose(_rotationLambda(deltaLambda),
                _rotationPhiGamma(deltaPhi, deltaGamma))
            : _rotationLambda(deltaLambda)
        : deltaPhi != 0 || deltaGamma != 0
            ? _rotationPhiGamma(deltaPhi, deltaGamma)
            : _rotationIdentity;

List<num> Function(List<num>) _forwardRotationLambda(double deltaLambda) =>
    (p) {
      var lambda = p[0] + deltaLambda;
      if (abs(lambda) > pi) lambda -= round(lambda / tau) * tau;
      return [lambda, p[1]];
    };

GeoRawTransform _rotationLambda(double deltaLambda) => GeoRawTransform(
    _forwardRotationLambda(deltaLambda), _forwardRotationLambda(-deltaLambda));

GeoRawTransform _rotationPhiGamma(double deltaPhi, deltaGamma) {
  final cosDeltaPhi = cos(deltaPhi),
      sinDeltaPhi = sin(deltaPhi),
      cosDeltaGamma = cos(deltaGamma),
      sinDeltaGamma = sin(deltaGamma);

  return GeoRawTransform((p) {
    var lambda = p[0],
        phi = p[1],
        cosPhi = cos(phi),
        x = cos(lambda) * cosPhi,
        y = sin(lambda) * cosPhi,
        z = sin(phi),
        k = z * cosDeltaPhi + x * sinDeltaPhi;
    return [
      atan2(y * cosDeltaGamma - k * sinDeltaGamma,
          x * cosDeltaPhi - z * sinDeltaPhi),
      asin(k * cosDeltaGamma + y * sinDeltaGamma)
    ];
  }, (p) {
    var lambda = p[0],
        phi = p[1],
        cosPhi = cos(phi),
        x = cos(lambda) * cosPhi,
        y = sin(lambda) * cosPhi,
        z = sin(phi),
        k = z * cosDeltaGamma - y * sinDeltaGamma;
    return [
      atan2(y * cosDeltaGamma + z * sinDeltaGamma,
          x * cosDeltaPhi + k * sinDeltaPhi),
      asin(k * cosDeltaPhi - x * sinDeltaPhi)
    ];
  });
}

/// A raw transform that represents a rotation about
/// [each spherical axis](https://observablehq.com/@d3/three-axis-rotation).
class GeoRotation implements GeoRawTransform {
  GeoRawTransform rotate;

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

  /// Returns a new array \[*longitude*, *latitude*\] in degrees representing
  /// the rotated point of the given *point*. The point must be specified as a
  /// two-element array \[*longitude*, *latitude*\] in degrees.
  @override
  get forward => (coordinates) {
        coordinates = rotate
            .forward([coordinates[0] * radians, coordinates[1] * radians]);
        coordinates[0] *= degrees;
        coordinates[1] *= degrees;
        return coordinates;
      };

  /// Returns a new array \[*longitude*, *latitude*\] in degrees representing
  /// the point of the given rotated *point*; the inverse of [forward]. The
  /// point must be specified as a two-element array \[*longitude*, *latitude*\]
  /// in degrees.
  @override
  get backward => (coordinates) {
        coordinates = rotate
            .backward!([coordinates[0] * radians, coordinates[1] * radians]);
        coordinates[0] *= degrees;
        coordinates[1] *= degrees;
        return coordinates;
      };
}
