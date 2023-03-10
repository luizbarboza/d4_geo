import '../math.dart';
import '../raw.dart';
import 'azimuthal.dart';
import 'projection.dart';

/// The raw orthographic projection.
final geoOrthographicRaw = GeoRawTransform((p) {
  var y = p[1];
  return [cos(y) * sin(p[0]), sin(y)];
}, azimuthalBackward(asin));

/// The orthographic projection.
GeoProjection geoOrthographic() => GeoProjection(geoOrthographicRaw)
  ..scale = 249.5
  ..clipAngle = 90 + epsilon;
