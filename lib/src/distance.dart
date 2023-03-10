import 'length.dart';
import 'path/path.dart';

List<List<num>?> _coordinates = [null, null];
Map _object = {"type": "LineString", "coordinates": _coordinates};

/// Returns the great-arc distance in
/// [radians](http://mathworld.wolfram.com/Radian.html) between the two points
/// [a] and [b].
///
/// Each point must be specified as a two-element array \[*longitude*,
/// *latitude*\] in degrees. This is the spherical equivalent of
/// [GeoPath.measure] given a LineString of two points.
double geoDistance(List<num> a, List<num> b) {
  _coordinates[0] = a;
  _coordinates[1] = b;
  return geoLength(_object);
}
