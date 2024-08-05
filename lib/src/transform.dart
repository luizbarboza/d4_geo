import 'path/path.dart';
import 'projection/identity.dart';
import 'projection/projection.dart';
import 'stream.dart';

/// Transforms are a generalization of projections.
///
/// Transform implement [GeoProjection.stream] and can be passed to
/// [GeoPath.transform]. However, transform only implements a subset of the
/// other projection methods, and represent arbitrary geometric transformations
/// rather than projections from spherical to planar coordinates.
///
/// {@category Projections}
class GeoTransform {
  final void Function(GeoStream, num, num, [num?])? _point;
  final void Function(GeoStream)? _sphere,
      _lineStart,
      _lineEnd,
      _polygonStart,
      _polygonEnd;

  /// Defines an arbitrary transform using the methods defined on the specified
  /// methods object.
  ///
  /// Any undefined methods will use pass-through *methods* that propagate
  /// inputs to the output stream. For example, to reflect the *y*-dimension
  /// (see also [GeoIdentity.reflectX]):
  ///
  /// ```dart
  /// var reflectY = GeoTransform(point: (stream, x, y, [z]) {
  ///   stream.point([x, -y]);
  /// });
  /// ```
  ///
  /// Or to define an affine matrix transformation:
  ///
  /// ```dart
  /// matrix(a, b, c, d, tx, ty) => GeoTransform(point: (stream, x, y, [z]) {
  ///       stream.point([a * x + b * y + tx, c * x + d * y + ty]);
  ///     });
  /// ```
  GeoTransform(
      {void Function(GeoStream, num, num, [num?])? point,
      void Function(GeoStream)? sphere,
      void Function(GeoStream)? lineStart,
      void Function(GeoStream)? lineEnd,
      void Function(GeoStream)? polygonStart,
      void Function(GeoStream)? polygonEnd})
      : _point = point,
        _sphere = sphere,
        _lineStart = lineStart,
        _lineEnd = lineEnd,
        _polygonStart = polygonStart,
        _polygonEnd = polygonEnd;

  GeoStream stream(GeoStream stream) {
    var s = TransformStream(stream);
    if (_point != null) s.point = (x, y, [z]) => _point!(stream, x, y, z);
    if (_sphere != null) s.sphere = () => _sphere!(stream);
    if (_lineStart != null) s.lineStart = () => _lineStart!(stream);
    if (_lineEnd != null) s.lineEnd = () => _lineEnd!(stream);
    if (_polygonStart != null) s.polygonStart = () => _polygonStart!(stream);
    if (_polygonEnd != null) s.polygonEnd = () => _polygonEnd!(stream);
    return s;
  }
}

class TransformStream extends GeoStream {
  TransformStream(GeoStream stream)
      : super(
            point: (x, y, [z]) => stream.point(x, y, z),
            sphere: () => stream.sphere(),
            lineStart: () => stream.lineStart(),
            lineEnd: () => stream.lineEnd(),
            polygonStart: () => stream.polygonStart(),
            polygonEnd: () => stream.polygonEnd());
}
