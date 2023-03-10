import 'distance.dart';
import 'math.dart';
import 'polygon_contains.dart';

Map<String, bool Function(Map, List<num>)> _containsObjectType = {
  "Feature": (object, point) => _containsGeometry(object['geometry'], point),
  "FeatureCollection": (object, point) {
    var features = List.castFrom<dynamic, Map>(object["features"]),
        i = -1,
        n = features.length;
    while (++i < n) {
      if (_containsGeometry(features[i]["geometry"], point)) {
        return true;
      }
    }
    return false;
  }
};

Map<String, bool Function(Map, List<num>)> _containsGeometryType = {
  "Sphere": (object, point) => true,
  "Point": (object, point) =>
      _containsPoint(List.castFrom<dynamic, num>(object["coordinates"]), point),
  "MultiPoint": (object, point) {
    var coordinates = List.castFrom<dynamic, List<num>>(object["coordinates"]),
        i = -1,
        n = coordinates.length;
    while (++i < n) {
      if (_containsPoint(coordinates[i], point)) {
        return true;
      }
    }
    return false;
  },
  "LineString": (object, point) => _containsLine(
      List.castFrom<dynamic, List<num>>(object["coordinates"]), point),
  "MultiLineString": (object, point) {
    var coordinates =
            List.castFrom<dynamic, List<List<num>>>(object["coordinates"]),
        i = -1,
        n = coordinates.length;
    while (++i < n) {
      if (_containsLine(coordinates[i], point)) {
        return true;
      }
    }
    return false;
  },
  "Polygon": (object, point) => _containsPolygon(
      List.castFrom<dynamic, List<List<num>>>(object["coordinates"]), point),
  "MultiPolygon": (object, point) {
    var coordinates = List.castFrom<dynamic, List<List<List<num>>>>(
            object["coordinates"]),
        i = -1,
        n = coordinates.length;
    while (++i < n) {
      if (_containsPolygon(coordinates[i], point)) {
        return true;
      }
    }
    return false;
  },
  "GeometryCollection": (object, point) {
    var geometries = List.castFrom<dynamic, Map>(object["geometries"]),
        i = -1,
        n = geometries.length;
    while (++i < n) {
      if (_containsGeometry(geometries[i], point)) {
        return true;
      }
    }
    return false;
  }
};

bool _containsGeometry(Map? geometry, List<num> point) =>
    geometry != null &&
    _containsGeometryType.containsKey(geometry["type"]) &&
    _containsGeometryType[geometry["type"]]!(geometry, point);

bool _containsPoint(List<num> coordinates, List<num> point) =>
    geoDistance(coordinates, point) == 0;

bool _containsLine(List<List<num>> coordinates, List<num> point) {
  late double ao, bo, ab;
  for (var i = 0, n = coordinates.length; i < n; i++) {
    bo = geoDistance(coordinates[i], point);
    if (bo == 0) return true;
    if (i > 0) {
      ab = geoDistance(coordinates[i], coordinates[i - 1]);
      if (ab > 0 &&
          ao <= ab &&
          bo <= ab &&
          (ao + bo - ab) * (1 - pow((ao - bo) / ab, 2)) < epsilon2 * ab) {
        return true;
      }
    }
    ao = bo;
  }
  return false;
}

bool _containsPolygon(List<List<List<num>>> coordinates, List<num> point) =>
    polygonContains(
        coordinates.map(_ringRadians).toList(), _pointRadians(point));

List<List<num>> _ringRadians(List<List<num>> ring) =>
    ring.map(_pointRadians).toList()..removeLast();

List<double> _pointRadians(List<num> point) =>
    [point[0] * radians, point[1] * radians];

/// Returns true if and only if the specified GeoJSON [object] contains the
/// specified [point], or false if the [object] does not contain the [point].
///
/// The point must be specified as a two-element array \[*longitude*,
/// *latitude*\]
/// in degrees. For Point and MultiPoint geometries, an exact test is used; for
/// a Sphere, true is always returned; for other geometries, an epsilon
/// threshold is applied.
bool geoContains(Map? object, List<num> point) =>
    object != null && _containsObjectType.containsKey(object['type'])
        ? _containsObjectType[object['type']]!(object, point)
        : _containsGeometry(object, point);
