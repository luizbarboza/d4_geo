import '../math.dart';
import '../raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw azimuthal equal-area projection.
final geoAzimuthalEqualAreaRaw = GeoRawTransform(
    azimuthalForward((cxcy) => sqrt(2 / (1 + cxcy))),
    azimuthalBackward((z) => 2 * asin(z / 2)));

/// The azimuthal equal-area projection.
GeoProjection geoAzimuthalEqualArea() => GeoProjection(geoAzimuthalEqualAreaRaw)
  ..scale = 124.75
  ..clipAngle = 180 - 1e-3;
