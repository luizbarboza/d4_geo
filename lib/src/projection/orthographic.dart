import '../math.dart';
import 'raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw orthographic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
final geoOrthographicRaw = GeoRawProjection((x, y, [_]) {
  return [cos(y) * sin(x), sin(y)];
}, azimuthalInvert(asin));

/// The orthographic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
GeoProjection geoOrthographic() => GeoProjection(geoOrthographicRaw)
  ..scale = 249.5
  ..clipAngle = 90 + epsilon;
