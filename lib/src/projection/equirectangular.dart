import '../identity.dart';
import '../raw.dart';
import 'projection.dart';

/// The raw equirectangular (plate carrée) projection.
const geoEquirectangularRaw = GeoRawTransform(identity, identity);

/// The equirectangular (plate carrée) projection.
GeoProjection geoEquirectangular() =>
    GeoProjection(geoEquirectangularRaw)..scale = 152.63;
