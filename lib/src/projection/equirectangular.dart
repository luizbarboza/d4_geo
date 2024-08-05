import 'raw.dart';
import 'projection.dart';

List<num> _equirectangularRaw(num lambda, num phi, [_]) {
  return [lambda, phi];
}

/// The raw equirectangular (plate carrée) projection.
///
/// {@category Projections}
/// {@category Cylindrical projections}
const geoEquirectangularRaw =
    GeoRawProjection(_equirectangularRaw, _equirectangularRaw);

/// The equirectangular (plate carrée) projection.
///
/// {@category Projections}
/// {@category Cylindrical projections}
GeoProjection geoEquirectangular() =>
    GeoProjection(geoEquirectangularRaw)..scale = 152.63;
