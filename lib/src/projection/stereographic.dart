import '../math.dart';
import 'raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw stereographic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
final geoStereographicRaw = GeoRawProjection((x, y, [_]) {
  var cy = cos(y), k = 1 + cos(x) * cy;
  return [cy * sin(x) / k, sin(y) / k];
}, azimuthalInvert((z) => 2 * atan(z)));

/// The stereographic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
GeoProjection geoStereographic() => GeoProjection(geoStereographicRaw)
  ..scale = 250
  ..clipAngle = 142;
