import '../math.dart';
import 'raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw gnomonic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
final geoGnomonicRaw = GeoRawProjection((x, y, [_]) {
  var cy = cos(y), k = cos(x) * cy;
  return [cy * sin(x) / k, sin(y) / k];
}, azimuthalInvert(atan));

/// The gnomonic projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
GeoProjection geoGnomonic() => GeoProjection(geoGnomonicRaw)
  ..scale = 144.049
  ..clipAngle = 60;
