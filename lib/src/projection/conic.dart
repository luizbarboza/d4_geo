import '../math.dart';
import '../raw.dart';
import 'projection.dart';

/// Conic projections project the sphere onto a cone, and then unroll the cone
/// onto the plane.
///
/// Conic projections have two standard parallels.
class GeoConicProjection extends GeoProjection {
  late GeoProjectionMutator _m;
  double _phi0, _phi1;

  GeoConicProjection._(
      GeoRawTransform Function(List<double>) projectAt, this._phi0, this._phi1)
      : super(projectAt([_phi0, _phi1])) {
    _m = GeoProjectionMutator<List<double>>(projectAt, this);
  }

  factory GeoConicProjection(
          GeoRawTransform Function(List<double>) projectAt) =>
      GeoConicProjection._(projectAt, 0, pi / 3);

  /// The
  /// [two standard parallels](https://en.wikipedia.org/wiki/Map_projection#Conic)
  /// that define the map layout in conic projections.
  List<double> get parallels => [_phi0 * degrees, _phi1 * degrees];
  set parallels(List<double> parallels) =>
      _m([_phi0 = parallels[0] * radians, _phi1 = parallels[1] * radians]);
}
