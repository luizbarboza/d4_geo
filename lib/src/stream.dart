import 'noop.dart';

/// Streams have several function-properties that are called to transform an
/// input geometry.
///
/// No materializations of intermediate representations are made, which
/// minimizes overhead. Streams are inherently stateful; the meaning of a point
/// depends on whether the point is inside of a line, and likewise a line is
/// distinguished from a ring by a polygon. Despite the name “stream”, these
/// method calls are currently synchronous.
class GeoStream {
  /// Indicates a point with the specified coordinates \[*x*, *y*\, (and
  /// optionally *z*)].
  ///
  /// The coordinate system is unspecified and implementation-dependent; for
  /// example, projection streams require spherical coordinates in degrees as
  /// input. Outside the context of a polygon or line, a point indicates a point
  /// geometry object ([Point](http://www.geojson.org/geojson-spec.html#point)
  /// or [MultiPoint](http://www.geojson.org/geojson-spec.html#multipoint)).
  /// Within a line or polygon ring, the point indicates a control point.
  void Function(List<num>) point;

  /// Indicates the start of a line or ring. Within a polygon, indicates the
  /// start of a ring.
  ///
  /// The first ring of a polygon is the exterior ring, and is typically
  /// clockwise. Any subsequent rings indicate holes in the polygon, and are
  /// typically counterclockwise.
  void Function() lineStart;

  /// Indicates the end of a line or ring. Within a polygon, indicates the end
  /// of a ring.
  ///
  /// Unlike GeoJSON, the redundant closing coordinate of a ring is not
  /// indicated via [point], and instead is implied via lineEnd within a
  /// polygon. Thus, the given polygon input:
  ///
  /// ```dart
  ///   {
  ///     "type": "Polygon",
  ///     "coordinates": [
  ///       [
  ///         [0, 0],
  ///         [0, 1],
  ///         [1, 1],
  ///         [1, 0],
  ///         [0, 0]
  ///       ]
  ///     ]
  ///   };
  /// ```
  ///
  /// Will produce the following series of method calls on the stream:
  ///
  /// ```dart
  ///   stream.polygonStart();
  ///   stream.lineStart();
  ///   stream.point(0, 0);
  ///   stream.point(0, 1);
  ///   stream.point(1, 1);
  ///   stream.point(1, 0);
  ///   stream.lineEnd();
  ///   stream.polygonEnd();
  /// ```
  void Function() lineEnd;

  /// Indicates the start of a polygon. The first line of a polygon indicates
  /// the exterior ring, and any subsequent lines indicate interior holes.
  void Function() polygonStart;

  /// Indicates the end of a polygon.
  void Function() polygonEnd;

  /// Indicates the sphere (the globe; the unit sphere centered at ⟨0,0,0⟩).
  void Function() sphere;

  GeoStream(
      {this.point = noop,
      this.sphere = noop,
      this.lineStart = noop,
      this.lineEnd = noop,
      this.polygonStart = noop,
      this.polygonEnd = noop});

  /// Streams the specified [GeoJSON](http://geojson.org/) *object*.
  ///
  /// While both features and geometry objects are supported as input, the
  /// stream only describes the geometry, and thus additional feature properties
  /// are not visible to streams.
  void call(Map? object) {
    if (object != null && _streamObjectType.containsKey(object['type'])) {
      _streamObjectType[object['type']]!(object);
    } else {
      _streamGeometry(object);
    }
  }

  void _streamGeometry(Map? geometry) {
    if (geometry != null && _streamGeometryType.containsKey(geometry['type'])) {
      _streamGeometryType[geometry['type']]!(geometry);
    }
  }

  late final Map<String, void Function(Map)> _streamObjectType = {
    'Feature': (object) {
      _streamGeometry(object['geometry']);
    },
    'FeatureCollection': (object) {
      var features = object['features'];
      for (var i = 0; i < features.length; i++) {
        _streamGeometry(features[i]['geometry']);
      }
    }
  };

  late final Map<String, void Function(Map)> _streamGeometryType = {
    'Sphere': (object) {
      sphere();
    },
    'Point': (object) {
      point(object['coordinates']);
    },
    'MultiPoint': (object) {
      var coordinates = object['coordinates'], i = -1, n = coordinates.length;
      while (++i < n) {
        point(coordinates[i]);
      }
    },
    'LineString': (object) {
      _streamLine(object['coordinates'], 0);
    },
    'MultiLineString': (object) {
      var coordinates = object['coordinates'], i = -1, n = coordinates.length;
      while (++i < n) {
        _streamLine(coordinates[i], 0);
      }
    },
    'Polygon': (object) {
      _streamPolygon(object['coordinates']);
    },
    'MultiPolygon': (object) {
      var coordinates = object['coordinates'], i = -1, n = coordinates.length;
      while (++i < n) {
        _streamPolygon(coordinates[i]);
      }
    },
    'GeometryCollection': (object) {
      var geometries = object['geometries'], i = -1, n = geometries.length;
      while (++i < n) {
        _streamGeometry(geometries[i]);
      }
    }
  };

  void _streamLine(coordinates, int closed) {
    var i = -1, n = coordinates.length - closed;
    lineStart();
    while (++i < n) {
      point(List.castFrom<dynamic, num>(coordinates[i]));
    }
    lineEnd();
  }

  void _streamPolygon(coordinates) {
    var i = -1, n = coordinates.length;
    polygonStart();
    while (++i < n) {
      _streamLine(coordinates[i], 1);
    }
    polygonEnd();
  }
}
