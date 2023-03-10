import '../math.dart';
import '../raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw stereographic projection.
final geoStereographicRaw = GeoRawTransform((p) {
  var x = p[0], y = p[1], cy = cos(y), k = 1 + cos(x) * cy;
  return [cy * sin(x) / k, sin(y) / k];
}, azimuthalBackward((z) => 2 * atan(z)));

/// The stereographic projection.
GeoProjection geoStereographic() => GeoProjection(geoStereographicRaw)
  ..scale = 250
  ..clipAngle = 142;
