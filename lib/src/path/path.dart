import '../constant.dart';
import '../identity.dart';
import '../stream.dart';
import '../transform.dart';
import 'area.dart' as planar;
import 'bounds.dart' as planar;
import 'centroid.dart' as planar;
import 'context.dart';
import 'measure.dart' as planar;
import 'sink.dart';
import 'string.dart';

/// A geometry geographic generator for creating paths.
///
/// It is similar to the shape generators in
/// [d3-shape](https://github.com/d3/d3-shape): given a GeoJSON geometry or
/// feature object, it generates an SVG path data string or
/// [renders the path to a Canvas](https://observablehq.com/@d3/u-s-map-canvas).
/// Canvas is recommended for dynamic or interactive projections to improve
/// performance. Paths can be used with projections or transforms, or they can
/// be used to render planar geometry directly to Canvas or SVG.
class GeoPath {
  GeoTransform? _transform;
  late GeoStream Function(GeoStream) _transformStream;
  late GeoPathContext? _context;
  late GeoPathSink _sink;

  /// A function which is computed per feature and used to display Point and
  /// MultiPoint geometries with the radius being the returned number.
  ///
  /// For example, if your GeoJSON data has additional properties, you might
  /// access those properties inside the radius function to vary the point size.
  double Function(Map?) pointRadius = constant(4.5);

  /// Creates a new geographic path generator with the default settings.
  ///
  /// If [transform] is specified, sets the current transform. If [context] is
  /// specified, sets the current context.
  GeoPath([GeoTransform? transform, GeoPathContext? context]) {
    this.transform = transform;
    this.context = context;
  }

  /// Renders the given [object], which may be any GeoJSON feature or geometry
  /// object:
  ///
  /// * Point - a single position.
  /// * MultiPoint - an array of positions.
  /// * LineString - an array of positions forming a continuous line.
  /// * MultiLineString - an array of arrays of positions forming several lines.
  /// * Polygon - an array of arrays of positions forming a polygon (possibly
  /// with holes).
  /// * MultiPolygon - a multidimensional array of positions forming multiple
  /// polygons.
  /// * GeometryCollection - an array of geometry objects.
  /// * Feature - a feature containing one of the above geometry objects.
  /// * FeatureCollection - an array of feature objects.
  ///
  /// The type *Sphere* is also supported, which is useful for rendering the
  /// outline of the globe; a sphere has no coordinates.
  ///
  /// To display multiple features, combine them into a feature collection:
  ///
  /// ```dart
  ///   GeoPath()({"type": "FeatureCollection", "features": features});
  /// ```
  ///
  /// Or use multiple path elements:
  ///
  /// ```dart
  ///   var path = GeoPath();
  ///   for (feature in features) {
  ///     path(feature);
  ///   }
  /// ```
  ///
  /// Separate path elements are typically slower than a single path element.
  /// However, distinct path elements are useful for styling and interaction
  /// (e.g., click or mouseover). Canvas rendering (see [GeoPathContext]) is
  /// typically faster than SVG, but requires more effort to implement styling
  /// and interaction.
  Object? call([Map? object]) {
    _sink.pointRadius(pointRadius(object));
    _transformStream(_sink)(object);
    return _sink.result();
  }

  /// Returns the projected planar area (typically in square pixels) for the
  /// specified GeoJSON [object].
  ///
  /// Point, MultiPoint, LineString and MultiLineString geometries have zero
  /// area. For Polygon and MultiPolygon geometries, this method first computes
  /// the area of the exterior ring, and then subtracts the area of any interior
  /// holes. This method observes any clipping performed by the [transform].
  double area(Map object) => planar.area(object, _transformStream);

  /// Returns the projected planar length (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// Point and MultiPoint geometries have zero length. For Polygon and
  /// MultiPolygon geometries, this method computes the summed length of all
  /// rings. This method observes any clipping performed by the [transform].
  double measure(Map object) => planar.measure(object, _transformStream);

  /// Returns the projected planar bounding box (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// The bounding box is represented by a
  /// two-dimensional array: \[\[*x₀*, *y₀*\], \[*x₁*, *y₁*\]\], where *x₀* is
  /// the minimum *x*-coordinate, *y₀* is the minimum *y*-coordinate, *x₁* is
  /// maximum *x*-coordinate, and *y₁* is the maximum *y*-coordinate. This is
  /// handy for, say, zooming in to a particular feature. (Note that in
  /// projected planar coordinates, the minimum latitude is typically the
  /// maximum *y*-value, and the maximum latitude is typically the minimum
  /// *y*-value.) This method observes any clipping performed by the
  /// [transform].
  List<List<num>> bounds(Map object) => planar.bounds(object, _transformStream);

  /// Returns the projected planar centroid (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// This is handy for, say, labeling state or county boundaries, or displaying
  /// a symbol map. For example, a
  /// [noncontiguous cartogram](https://observablehq.com/@d3/non-contiguous-cartogram)
  /// might scale each state around its centroid. This method observes any
  /// clipping performed by the [transform].
  List<double> centroid(Map object) =>
      planar.centroid(object, _transformStream);

  /// A transform applied to any input geometry before it is rendered.
  ///
  /// The `null` transform represents the identity transformation: the
  /// input geometry is not transformed and is instead rendered directly in raw
  /// coordinates. This can be useful for fast rendering of
  /// [pre-projected geometry](https://bl.ocks.org/mbostock/5557726),
  /// or for fast rendering of the equirectangular projection.
  ///
  /// Is typically one of built-in geographic projections; however, any object
  /// that implements [GeoTransform] can be used, enabling the use of
  /// [custom projections](https://bl.ocks.org/mbostock/5663666).
  GeoTransform? get transform => _transform;
  set transform(GeoTransform? _) {
    if (_ == null) {
      _transform = null;
      _transformStream = identity;
    } else {
      _transformStream = (_transform = _);
    }
  }

  /// Context used to render the path.
  ///
  /// If the context is `null`, then the path generator will return an SVG path
  /// string; if the context is non-null, the path generator will instead call
  /// methods on the specified context to render geometry.
  /// The context must created with the following subset of the
  /// CanvasRenderingContext2D API:
  ///
  /// * context.moveTo(x, y)
  /// * context.lineTo(x, y)
  /// * context.arc(x, y, radius, startAngle, endAngle)
  /// * context.closePath()
  GeoPathContext? get context => _context;
  set context(GeoPathContext? _) {
    _sink = (_context = _) != null ? _! : GeoPathString();
  }
}
