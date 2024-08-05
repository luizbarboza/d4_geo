import '../math.dart';
import 'raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw azimuthal equal-area projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
final geoAzimuthalEqualAreaRaw = GeoRawProjection(
    azimuthalRaw((cxcy) => sqrt(2 / (1 + cxcy))),
    azimuthalInvert((z) => 2 * asin(z / 2)));

/// The azimuthal equal-area projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
GeoProjection geoAzimuthalEqualArea() => GeoProjection(geoAzimuthalEqualAreaRaw)
  ..scale = 124.75
  ..clipAngle = 180 - 1e-3;
