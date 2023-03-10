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
class GeoIdentity implements GeoProjection {
  double _k = 1, _tx = 0, _ty = 0; // scale and translate
  int _sx = 1, _sy = 1; // reflect
  late double _alpha = 0, _ca, _sa; // angle
  double? _x0, _y0, _x1, _y1; // clip extent
  double _kx = 1, _ky = 1;
  late final GeoStream Function(GeoStream) _transform =
      GeoTransform(point: (stream, p) {
    stream.point(forward(p));
  });
  GeoStream Function(GeoStream) _postclip = identity;
  GeoStream? _cache, _cacheStream;

  _reset() {
    _kx = _k * _sx;
    _ky = _k * _sy;
    _cache = _cacheStream = null;
    return this;
  }

  @override
  get forward => (p) {
        var x = p[0] * _kx, y = p[1] * _ky;
        if (_alpha != 0) {
          var t = y * _ca - x * _sa;
          x = x * _ca + y * _sa;
          y = t;
        }
        return [x + _tx, y + _ty];
      };

  @override
  get backward => (p) {
        var x = p[0] - _tx, y = p[1] - _ty;
        if (_alpha != 0) {
          var t = y * _ca + x * _sa;
          x = x * _ca - y * _sa;
          y = t;
        }
        return [x / _kx, y / _ky];
      };

  @override
  call(stream) => _cache != null && _cacheStream == stream
      ? _cache!
      : _cache = _transform(postclip(_cacheStream = stream));

  @override
  set postclip(_) {
    _postclip = _;
    _x0 = _y0 = _x1 = _y1 = null;
    _reset();
  }

  @override
  get postclip => _postclip;

  @override
  set clipExtent(_) {
    if (_ == null) {
      _x0 = _y0 = _x1 = _y1 = null;
      _postclip = identity;
      return;
    } else {
      _postclip = geoClipRectangle(
          _x0 = _[0][0], _y0 = _[0][1], _x1 = _[1][0], _y1 = _[1][1]);
    }
    _reset();
  }

  @override
  get clipExtent => _x0 == null
      ? null
      : [
          [_x0!, _y0!],
          [_x1!, _y1!]
        ];

  @override
  set scale(_) {
    _k = _;
    _reset();
  }

  @override
  get scale => _k;

  @override
  set translate(_) {
    _tx = _[0];
    _ty = _[1];
    _reset();
  }

  @override
  get translate => [_tx, _ty];

  @override
  set angle(_) {
    _alpha = _.remainder(360) * radians;
    _sa = sin(_alpha);
    _ca = cos(_alpha);
    _reset();
  }

  @override
  get angle => _alpha * degrees;

  @override
  set reflectX(_) {
    _sx = _ ? -1 : 1;
    _reset();
  }

  @override
  get reflectX => _sx < 0;

  @override
  set reflectY(_) {
    _sy = _ ? -1 : 1;
    _reset();
  }

  @override
  get reflectY => _sy < 0;

  @override
  fitExtent(extent, object) {
    fit.extent(this, extent, object);
  }

  @override
  fitSize(size, object) {
    fit.size(this, size, object);
  }

  @override
  fitWidth(width, object) {
    fit.width(this, width, object);
  }

  @override
  fitHeight(height, object) {
    fit.height(this, height, object);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
