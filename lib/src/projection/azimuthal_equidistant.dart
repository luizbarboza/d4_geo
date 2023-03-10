import '../math.dart';
import '../raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw azimuthal equidistant projection.
final geoAzimuthalEquidistantRaw = GeoRawTransform(
    azimuthalForward((c) => (c = acos(c)) == 0 ? c : c / sin(c)),
    azimuthalBackward((z) => z));

/// The azimuthal equidistant projection.
GeoProjection geoAzimuthalEquidistant() =>
    GeoProjection(geoAzimuthalEquidistantRaw)
      ..scale = 79.4188
      ..clipAngle = 180 - 1e-3;
