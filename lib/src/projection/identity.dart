import '../clip/rectangle.dart';
import '../identity.dart';
import '../math.dart';
import '../stream.dart';
import '../transform.dart';
import 'fit.dart' as fit;
import 'projection.dart';

/// The identity transform can be used to scale, translate and clip planar
/// geometry.
///
/// It implements [GeoProjection.scale], [GeoProjection.translate],
/// [GeoProjection.fitExtent], [GeoProjection.fitSize],
/// [GeoProjection.fitWidth], [GeoProjection.fitHeight],
/// [GeoProjection.clipExtent], [GeoProjection.angle], [GeoProjection.reflectX]
/// and [GeoProjection.reflectY].
///
/// {@category Projections}
class GeoIdentity implements GeoTransform {
  double _k = 1, _tx = 0, _ty = 0; // scale and translate
  int _sx = 1, _sy = 1; // reflect
  late double _alpha = 0, _ca, _sa; // angle
  double? _x0, _y0, _x1, _y1; // clip extent
  double _kx = 1, _ky = 1;
  late final GeoStream Function(GeoStream) _transform =
      GeoTransform(point: (stream, x, y, [_]) {
    final p = call([x, y]);
    stream.point(p[0], p[1]);
  }).stream;
  GeoStream Function(GeoStream) _postclip = identity;
  GeoStream? _cache, _cacheStream;

  void _reset() {
    _kx = _k * _sx;
    _ky = _k * _sy;
    _cache = _cacheStream = null;
  }

  List<num> call(List<num> point) {
    var x = point[0] * _kx, y = point[1] * _ky;
    if (_alpha != 0) {
      var t = y * _ca - x * _sa;
      x = x * _ca + y * _sa;
      y = t;
    }
    return [x + _tx, y + _ty];
  }

  List<num> invert(List<num> point) {
    var x = point[0] - _tx, y = point[1] - _ty;
    if (_alpha != 0) {
      var t = y * _ca + x * _sa;
      x = x * _ca - y * _sa;
      y = t;
    }
    return [x / _kx, y / _ky];
  }

  @override
  stream(stream) => _cache != null && _cacheStream == stream
      ? _cache!
      : _cache = _transform(postclip(_cacheStream = stream));

  /// Equivalent to [GeoProjection.postclip].
  GeoStream Function(GeoStream) get postclip => _postclip;
  set postclip(GeoStream Function(GeoStream) postclip) {
    _postclip = postclip;
    _x0 = _y0 = _x1 = _y1 = null;
    _reset();
  }

  /// Equivalent to [GeoProjection.clipExtent].
  List<List<double>>? get clipExtent => _x0 == null
      ? null
      : [
          [_x0!, _y0!],
          [_x1!, _y1!]
        ];
  set clipExtent(List<List<double>>? clipExtent) {
    if (clipExtent == null) {
      _x0 = _y0 = _x1 = _y1 = null;
      _postclip = identity;
      return;
    } else {
      _postclip = geoClipRectangle(
          _x0 = clipExtent[0][0],
          _y0 = clipExtent[0][1],
          _x1 = clipExtent[1][0],
          _y1 = clipExtent[1][1]);
    }
    _reset();
  }

  /// Equivalent to [GeoProjection.scale].
  double get scale => _k;
  set scale(double scale) {
    _k = scale;
    _reset();
  }

  /// Equivalent to [GeoProjection.translate].
  List<double> get translate => [_tx, _ty];
  set translate(List<double> translate) {
    _tx = translate[0];
    _ty = translate[1];
    _reset();
  }

  /// Equivalent to [GeoProjection.angle].
  double get angle => _alpha * degrees;
  set angle(double angle) {
    _alpha = angle.remainder(360) * radians;
    _sa = sin(_alpha);
    _ca = cos(_alpha);
    _reset();
  }

  /// Equivalent to [GeoProjection.reflectX].
  bool get reflectX => _sx < 0;
  set reflectX(bool reflectX) {
    _sx = reflectX ? -1 : 1;
    _reset();
  }

  /// Equivalent to [GeoProjection.reflectY].
  bool get reflectY => _sy < 0;
  set reflectY(bool reflectY) {
    _sy = reflectY ? -1 : 1;
    _reset();
  }

  /// Equivalent to [GeoProjection.fitExtent].
  void fitExtent(List<List<double>> extent, Map object) {
    fit.extent(this, extent, object);
  }

  /// Equivalent to [GeoProjection.fitSize].
  void fitSize(List<double> size, Map object) {
    fit.size(this, size, object);
  }

  /// Equivalent to [GeoProjection.fitWidth].
  void fitWidth(double width, Map object) {
    fit.width(this, width, object);
  }

  /// Equivalent to [GeoProjection.fitHeight].
  void fitHeight(double height, Map object) {
    fit.height(this, height, object);
  }
}
