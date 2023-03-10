import '../math.dart';
import '../raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw gnomonic projection.
final geoGnomonicRaw = GeoRawTransform((p) {
  var x = p[0], y = p[1], cy = cos(y), k = cos(x) * cy;
  return [cy * sin(x) / k, sin(y) / k];
}, azimuthalBackward(atan));

/// The gnomonic projection.
GeoProjection geoGnomonic() => GeoProjection(geoGnomonicRaw)
  ..scale = 144.049
  ..clipAngle = 60;
