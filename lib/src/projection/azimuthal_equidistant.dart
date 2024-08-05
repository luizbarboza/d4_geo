import '../math.dart';
import 'raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw azimuthal equidistant projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
final geoAzimuthalEquidistantRaw = GeoRawProjection(
    azimuthalRaw((c) => (c = acos(c)) == 0 ? c : c / sin(c)),
    azimuthalInvert((z) => z));

/// The azimuthal equidistant projection.
///
/// {@category Projections}
/// {@category Azimuthal projections}
GeoProjection geoAzimuthalEquidistant() =>
    GeoProjection(geoAzimuthalEquidistantRaw)
      ..scale = 79.4188
      ..clipAngle = 180 - 1e-3;
