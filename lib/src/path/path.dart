import 'package:d4_path/d4_path.dart';

import '../area.dart';
import '../bounds.dart';
import '../centroid.dart';
import '../constant.dart';
import '../identity.dart';
import '../length.dart';
import '../projection/projection.dart';
import '../stream.dart';
import '../transform.dart';
import 'area.dart' as planar;
import 'bounds.dart' as planar;
import 'centroid.dart' as planar;
import 'context.dart';
import 'measure.dart' as planar;
import 'sink.dart';
import 'string.dart';

/// A geographic path generator that takes a given GeoJSON geometry or feature
/// object and generates SVG path data string or
/// [renders to a Canvas](https://observablehq.com/@d3/u-s-map-canvas).
///
/// Paths can be used with
/// [projections](https://pub.dev/documentation/d4_geo/latest/topics/Projections-topic.html)
/// or
/// [transforms](https://pub.dev/documentation/d4_geo/latest/d4_geo/GeoTransform-class.html),
/// or they can be used to render planar geometry directly to Canvas or SVG.
///
/// {@category Paths}
class GeoPath {
  GeoTransform? _transform;
  Path? _context;
  late GeoStream Function(GeoStream) _transformStream;
  late GeoPathSink _sink;

  /// A function which is computed per feature and used to display Point and
  /// MultiPoint geometries with the radius being the returned number.
  ///
  /// ```dart
  /// final path = GeoPath()..pointRadius = (object, [arguments]) => 10;
  ///
  /// path.pointRadius // 10
  /// ```
  ///
  /// For example, if your GeoJSON data has additional properties, you might
  /// access those properties inside the radius function to vary the point size;
  /// alternatively, you could
  /// [symbol](https://pub.dev/documentation/d4_shape/latest/topics/Symbols-topic.html)
  /// and a
  /// [projection](https://pub.dev/documentation/d4_geo/latest/topics/Projections-topic.html)
  /// for greater flexibility.
  double Function(Map?, [List? arguments]) pointRadius = constant(4.5);

  /// Creates a new geographic path generator with the default settings.
  ///
  /// ```dart
  /// final path = GeoPath(transform); // for SVG
  /// ```
  /// ```dart
  /// final path = GeoPath(transform, context); // for canvas
  /// ```
  ///
  /// If [transform] is specified, sets the current transform. If [context] is
  /// specified, sets the current context.
  GeoPath([GeoTransform? transform, Path? context]) {
    this.transform = transform;
    this.context = context;
  }

  /// Renders the given [object], which may be any GeoJSON feature or geometry
  /// object:
  ///
  /// * *Point* - a single position.
  /// * *MultiPoint* - an list of positions.
  /// * *LineString* - an list of positions forming a continuous line.
  /// * *MultiLineString* - an list of list of positions forming several lines.
  /// * *Polygon* - an list of lists of positions forming a polygon (possibly
  /// with holes).
  /// * *MultiPolygon* - a multidimensional list of positions forming multiple
  /// polygons.
  /// * *GeometryCollection* - an list of geometry objects.
  /// * *Feature* - a feature containing one of the above geometry objects.
  /// * *FeatureCollection* - an list of feature objects.
  ///
  /// The type *Sphere* is also supported, which is useful for rendering the
  /// outline of the globe; a sphere has no coordinates. Any additional
  /// arguments are passed along to the [pointRadius] accessor.
  ///
  /// To display multiple features, combine them into a feature collection:
  ///
  /// ```dart
  /// GeoPath()({"type": "FeatureCollection", "features": features});
  /// ```
  ///
  /// Or use multiple path elements:
  ///
  /// ```dart
  /// var path = GeoPath();
  /// for (feature in features) {
  ///   path(feature);
  /// }
  /// ```
  ///
  /// Separate path elements are typically slower than a single path element.
  /// However, distinct path elements are useful for styling and interaction
  /// (e.g., click or mouseover). Canvas rendering (see [context]) is
  /// typically faster than SVG, but requires more effort to implement styling
  /// and interaction.
  String? call([Map? object, List? arguments]) {
    _sink.pointRadius(pointRadius(object, arguments));
    _transformStream(_sink)(object);
    return _sink.result();
  }

  /// Returns the projected planar area (typically in square pixels) for the
  /// specified GeoJSON [object].
  ///
  /// ```dart
  /// path.area(california) // 17063.1671837991 px²
  /// ```
  ///
  /// Point, MultiPoint, LineString and MultiLineString geometries have zero
  /// area. For Polygon and MultiPolygon geometries, this method first computes
  /// the area of the exterior ring, and then subtracts the area of any interior
  /// holes. This method observes any clipping performed by the [transform]; see
  /// [GeoProjection.clipAngle] and [GeoProjection.clipExtent]. This is the
  /// planar equivalent of [geoArea].
  double area(Map object) => planar.area(object, _transformStream);

  /// Returns the projected planar length (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// ```dart
  /// path.measure(california) // 825.7124297512761
  /// ```
  ///
  /// Point and MultiPoint geometries have zero length. For Polygon and
  /// MultiPolygon geometries, this method computes the summed length of all
  /// rings. This method observes any clipping performed by the [transform]; see
  /// [GeoProjection.clipAngle] and [GeoProjection.clipExtent]. This is the
  /// planar equivalent of [geoLength].
  double measure(Map object) => planar.measure(object, _transformStream);

  /// Returns the projected planar bounding box (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// ```dart
  /// path.bounds(california) // [[18.48513821663947, 159.95146883594333], [162.7651668852596, 407.09641570706725]]
  /// ```
  ///
  /// The bounding box is represented by a
  /// two-dimensional array: \[\[*x₀*, *y₀*\], \[*x₁*, *y₁*\]\], where *x₀* is
  /// the minimum *x*-coordinate, *y₀* is the minimum *y*-coordinate, *x₁* is
  /// maximum *x*-coordinate, and *y₁* is the maximum *y*-coordinate. This is
  /// handy for, say, zooming in to a particular feature. (Note that in
  /// projected planar coordinates, the minimum latitude is typically the
  /// maximum *y*-value, and the maximum latitude is typically the minimum
  /// *y*-value.) This method observes any clipping performed by the
  /// [transform]; see [GeoProjection.clipAngle] and [GeoProjection.clipExtent].
  /// This is the planar equivalent of [geoBounds].
  List<List<num>> bounds(Map object) => planar.bounds(object, _transformStream);

  /// Returns the projected planar centroid (typically in pixels) for the
  /// specified GeoJSON [object].
  ///
  /// ```dart
  /// path.centroid(california) // [82.08679434495191, 288.14204870673404]
  /// ```
  ///
  /// This is handy for, say, labeling state or county boundaries, or displaying
  /// a symbol map. For example, a
  /// [noncontiguous cartogram](https://observablehq.com/@d3/non-contiguous-cartogram)
  /// might scale each state around its centroid. This method observes any
  /// clipping performed by the [transform]; see [GeoProjection.clipAngle] and
  /// [GeoProjection.clipExtent]. This is the planar equivalent of
  /// [geoCentroid].
  List<double> centroid(Map object) =>
      planar.centroid(object, _transformStream);

  /// A transform applied to any input geometry before it is rendered.
  ///
  /// ```dart
  /// final path = GeoPath()..transform = geoAlbers();
  ///
  /// path.projection() // a geoAlbers instance
  /// ```
  ///
  /// The `null` transform represents the identity transformation: the
  /// input geometry is not transformed and is instead rendered directly in raw
  /// coordinates. This can be useful for fast rendering of
  /// [pre-projected geometry](https://observablehq.com/@d3/u-s-map), or for
  /// fast rendering of the equirectangular projection.
  ///
  /// The given [transform] is typically one of D4’s built-in
  /// [geographic projections](https://pub.dev/documentation/d4_geo/latest/topics/Projections-topic.html);
  /// however, any object that implements [GeoTransform] can be used, enabling
  /// the use of
  /// [custom projections](https://observablehq.com/@d3/custom-cartesian-projection).
  /// See [GeoTransform.new] for more examples of arbitrary geometric
  /// transformations.
  GeoTransform? get transform => _transform;
  set transform(GeoTransform? transform) {
    if (transform == null) {
      _transform = null;
      _transformStream = identity;
    } else {
      _transformStream = (_transform = transform).stream;
    }
  }

  /// Context used to render the path.
  ///
  /// ```dart
  /// final context = …;
  /// final path = GeoPath()..context = context;
  ///
  /// path.context; // context
  /// ```
  ///
  /// If the [context] is `null`, then the path generator will return an SVG
  /// path string; if the context is non-null, the path generator will instead
  /// call methods on the specified context to render geometry. The context must
  /// implement the [Path] interface.
  ///
  /// Defaults to null.
  Path? get context => _context;
  set context(Path? context) {
    _sink = (_context = context) != null
        ? GeoPathContext(context!)
        : GeoPathString();
  }
}
