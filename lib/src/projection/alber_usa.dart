import '../math.dart';
import '../stream.dart';
import 'albers.dart';
import 'conic_equal_area.dart';
import 'fit.dart' as fit;
import 'projection.dart';

// The projections must have mutually exclusive clip regions on the sphere,
// as this will avoid emitting interleaving lines and polygons.
GeoStream _multiplex(List<GeoStream> streams) {
  var n = streams.length;
  return GeoStream(point: (p) {
    var i = -1;
    while (++i < n) {
      streams[i].point(p);
    }
  }, sphere: () {
    var i = -1;
    while (++i < n) {
      streams[i].sphere();
    }
  }, lineStart: () {
    var i = -1;
    while (++i < n) {
      streams[i].lineStart();
    }
  }, lineEnd: () {
    var i = -1;
    while (++i < n) {
      streams[i].lineEnd();
    }
  }, polygonStart: () {
    var i = -1;
    while (++i < n) {
      streams[i].polygonStart();
    }
  }, polygonEnd: () {
    var i = -1;
    while (++i < n) {
      streams[i].polygonEnd();
    }
  });
}

// A composite projection for the United States, configured by default for
// 960×500. The projection also works quite well at 960×600 if you change the
// scale to 1285 and adjust the translate accordingly. The set of standard
// parallels for each region comes from USGS, which is published here:
// http://egsc.usgs.gov/isb/pubs/MapProjections/projections.html#albers

/// A U.S.-centric composite projection of three [geoConicEqualArea]
/// projections.
///
/// [geoAlbers] is used for the lower forty-eight states, and separate conic
/// equal-area projections are used for Alaska and Hawaii. Note that the scale
/// for Alaska is diminished: it is projected at 0.35× its true relative area.
///
/// See
/// [Albers USA with Territories](https://www.npmjs.com/package/geo-albers-usa-territories)
/// for an extension to all US territories, and
/// [d3-composite-projections](http://geoexamples.com/d3-composite-projections/)
/// for more examples.
class GeoAlbersUsa implements GeoProjection {
  GeoStream? _cache, _cacheStream;
  final GeoProjection _lower48 = geoAlbers(),
      _alaska = geoConicEqualArea()
        ..rotate = [154, 0]
        ..center = [-2, 58.5]
        ..parallels = [55, 65],
      _hawaii = geoConicEqualArea()
        ..rotate = [157, 0]
        ..center = [-3, 19.9]
        ..parallels = [8, 18];
  late GeoStream _lower48Point,
      _alaskaPoint, // EPSG:3338
      _hawaiiPoint; // ESRI:102007
  late final GeoStream _pointStream = GeoStream(point: (p) {
    _inside = true;
    _point = p;
  });
  late bool _inside;
  late List<num> _point;

  GeoAlbersUsa() {
    scale = 1070;
  }

  @override
  get forward => (coordinates) {
        _inside = false;
        _point = [double.nan, double.nan];
        _lower48Point.point(coordinates);
        if (_inside) return _point;
        _alaskaPoint.point(coordinates);
        if (_inside) return _point;
        _hawaiiPoint.point(coordinates);
        return _point;
      };

  @override
  get backward => (coordinates) {
        var k = _lower48.scale,
            t = _lower48.translate,
            x = (coordinates[0] - t[0]) / k,
            y = (coordinates[1] - t[1]) / k;
        return (y >= 0.120 && y < 0.234 && x >= -0.425 && x < -0.214
                ? _alaska
                : y >= 0.166 && y < 0.234 && x >= -0.214 && x < -0.115
                    ? _hawaii
                    : _lower48)
            .backward!(coordinates);
      };

  @override
  call(GeoStream stream) => _cache != null && _cacheStream == stream
      ? _cache!
      : _cache = _multiplex(
          [_lower48(_cacheStream = stream), _alaska(stream), _hawaii(stream)]);

  @override
  set precision(_) {
    _lower48.precision = _;
    _alaska.precision = _;
    _hawaii.precision = _;
    _reset();
  }

  @override
  get precision => _lower48.precision;

  @override
  set scale(_) {
    _lower48.scale = _;
    _alaska.scale = _ * 0.35;
    _hawaii.scale = _;
    translate = _lower48.translate;
  }

  @override
  get scale => _lower48.scale;

  @override
  set translate(_) {
    var k = _lower48.scale, x = _[0], y = _[1];

    _lower48Point = (_lower48
      ..translate = _
      ..clipExtent = [
        [x - 0.455 * k, y - 0.238 * k],
        [x + 0.455 * k, y + 0.238 * k]
      ])(_pointStream);

    _alaskaPoint = (_alaska
      ..translate = [x - 0.307 * k, y + 0.201 * k]
      ..clipExtent = [
        [x - 0.425 * k + epsilon, y + 0.120 * k + epsilon],
        [x - 0.214 * k - epsilon, y + 0.234 * k - epsilon]
      ])(_pointStream);

    _hawaiiPoint = (_hawaii
      ..translate = [x - 0.205 * k, y + 0.212 * k]
      ..clipExtent = [
        [x - 0.214 * k + epsilon, y + 0.166 * k + epsilon],
        [x - 0.115 * k - epsilon, y + 0.234 * k - epsilon]
      ])(_pointStream);

    _reset();
  }

  @override
  get translate => _lower48.translate;

  @override
  fitExtent(extent, object) {
    fit.extent(this, extent, object, false);
  }

  @override
  fitSize(size, object) {
    fit.size(this, size, object, false);
  }

  @override
  fitWidth(width, object) {
    fit.width(this, width, object, false);
  }

  @override
  fitHeight(height, object) {
    fit.height(this, height, object, false);
  }

  _reset() {
    _cache = _cacheStream = null;
    return this;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
