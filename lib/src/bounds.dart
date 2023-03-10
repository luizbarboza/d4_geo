import 'adder.dart';
import 'area.dart';
import 'cartesian.dart';
import 'math.dart';
import 'path/path.dart';
import 'stream.dart';

late num _lambda0, _phi0, _lambda1, _phi1; // bounds
late num _lambda2; // previous lambda-coordinate
late List<num> _p00; // first point
List<double>? _p0;
late Adder _deltaSum;
List<List<num>>? _ranges;
List<num>? _range;

void _boundsPoint(List<num> p) {
  var lambda = p[0], phi = p[1];
  _ranges!.add(_range = [_lambda0 = lambda, _lambda1 = lambda]);
  if (phi < _phi0) _phi0 = phi;
  if (phi > _phi1) _phi1 = phi;
}

void _linePoint(List<num> s) {
  var lambda = s[0],
      phi = s[1],
      p = cartesian([lambda * radians, phi * radians]);
  if (_p0 != null) {
    var normal = cartesianCross(_p0!, p),
        equatorial = [normal[1], -normal[0], 0.0],
        inflection = cartesianCross(equatorial, normal);
    cartesianNormalizeInPlace(inflection);
    inflection = spherical(inflection);
    var delta = lambda - _lambda2,
        sign = delta > 0 ? 1 : -1,
        lambdai = inflection[0] * degrees * sign,
        antimeridian = abs(delta) > 180;
    double phii;
    if (antimeridian ^ (sign * _lambda2 < lambdai && lambdai < sign * lambda)) {
      phii = inflection[1] * degrees;
      if (phii > _phi1) _phi1 = phii;
    } else if (antimeridian ^
        (sign * _lambda2 < (lambdai = (lambdai + 360) % 360 - 180) &&
            lambdai < sign * lambda)) {
      phii = -inflection[1] * degrees;
      if (phii < _phi0) _phi0 = phii;
    } else {
      if (phi < _phi0) _phi0 = phi;
      if (phi > _phi1) _phi1 = phi;
    }
    if (antimeridian) {
      if (lambda < _lambda2) {
        if (_angle(_lambda0, lambda) > _angle(_lambda0, _lambda1)) {
          _lambda1 = lambda;
        }
      } else {
        if (_angle(lambda, _lambda1) > _angle(_lambda0, _lambda1)) {
          _lambda0 = lambda;
        }
      }
    } else {
      if (_lambda1 >= _lambda0) {
        if (lambda < _lambda0) _lambda0 = lambda;
        if (lambda > _lambda1) _lambda1 = lambda;
      } else {
        if (lambda > _lambda2) {
          if (_angle(_lambda0, lambda) > _angle(_lambda0, _lambda1)) {
            _lambda1 = lambda;
          }
        } else {
          if (_angle(lambda, _lambda1) > _angle(_lambda0, _lambda1)) {
            _lambda0 = lambda;
          }
        }
      }
    }
  } else {
    _ranges!.add(_range = [_lambda0 = lambda, _lambda1 = lambda]);
  }
  if (phi < _phi0) _phi0 = phi;
  if (phi > _phi1) _phi1 = phi;
  _p0 = p;
  _lambda2 = lambda;
}

void _boundsLineStart() {
  _boundsStream.point = _linePoint;
}

void _boundsLineEnd() {
  _range?[0] = _lambda0;
  _range?[1] = _lambda1;
  _boundsStream.point = _boundsPoint;
  _p0 = null;
}

void _boundsRingPoint(List<num> p) {
  if (_p0 != null) {
    var delta = p[0] - _lambda2;
    _deltaSum.add(
        abs(delta) > 180 ? delta + (delta > 0 ? 360 : -360) : delta.toDouble());
  } else {
    _p00 = p;
  }
  areaStream.point(p);
  _linePoint(p);
}

void _boundsRingStart() {
  areaStream.lineStart();
}

void _boundsRingEnd() {
  _boundsRingPoint(_p00);
  areaStream.lineEnd();
  if (abs(_deltaSum.valueOf()) > epsilon) _lambda0 = -(_lambda1 = 180);
  _range?[0] = _lambda0;
  _range?[1] = _lambda1;
  _p0 = null;
}

// Finds the left-right distance between two longitudes.
// This is almost the same as (lambda1 - lambda0 + 360°) % 360°,
// except that we want the distance between ±180° to be 360°.
num _angle(num lambda0, num lambda1) =>
    (lambda1 -= lambda0) < 0 ? lambda1 + 360 : lambda1;

int _rangeCompare(List<num> a, List<num> b) => a[0].compareTo(b[0]);

bool _rangeContains(List<num> range, num x) => range[0] <= range[1]
    ? range[0] <= x && x <= range[1]
    : x < range[0] || range[1] < x;

GeoStream _boundsStream = GeoStream(
    point: _boundsPoint,
    lineStart: _boundsLineStart,
    lineEnd: _boundsLineEnd,
    polygonStart: () {
      _boundsStream.point = _boundsRingPoint;
      _boundsStream.lineStart = _boundsRingStart;
      _boundsStream.lineEnd = _boundsRingEnd;
      _deltaSum = Adder();
      areaStream.polygonStart();
    },
    polygonEnd: () {
      areaStream.polygonEnd();
      _boundsStream.point = _boundsPoint;
      _boundsStream.lineStart = _boundsLineStart;
      _boundsStream.lineEnd = _boundsLineEnd;
      if (areaRingSum.valueOf() < 0) {
        _lambda0 = -(_lambda1 = 180);
        _phi0 = -(_phi1 = 90);
      } else if (_deltaSum.valueOf() > epsilon) {
        _phi1 = 90;
      } else if (_deltaSum.valueOf() < -epsilon) {
        _phi0 = -90;
      }
      _range?[0] = _lambda0;
      _range?[1] = _lambda1;
    },
    sphere: () {
      _lambda0 = -(_lambda1 = 180);
      _phi0 = -(_phi1 = 90);
    });

/// Returns the
/// [spherical bounding box](https://www.jasondavies.com/maps/bounds/) for the
/// specified GeoJSON [object].
///
/// The bounding box is represented by a two-dimensional array: \[\[*left*,
/// *bottom*\], \[*right*, *top*\]\], where *left* is the minimum longitude,
/// *bottom* is the minimum latitude, *right* is maximum longitude, and *top* is
/// the maximum latitude. All coordinates are given in degrees. (Note that in
/// projected planar coordinates, the minimum latitude is typically the maximum
/// *y*-value, and the maximum latitude is typically the minimum *y*-value.)
/// This is the spherical equivalent of [GeoPath.bounds].
List<List<num>> geoBounds(Map object) {
  int i, n;
  List<num> a, b;
  List<List<num>> merged;
  num deltaMax, delta;

  _phi1 = _lambda1 = -(_lambda0 = _phi0 = double.infinity);
  _ranges = [];
  _boundsStream(object);

  // First, sort ranges by their minimum longitudes.
  if ((n = _ranges!.length) != 0) {
    _ranges!.sort(_rangeCompare);

    // Then, merge any ranges that overlap.
    a = _ranges![0];
    merged = [a];
    for (i = 1; i < n; ++i) {
      b = _ranges![i];
      if (_rangeContains(a, b[0]) || _rangeContains(a, b[1])) {
        if (_angle(a[0], b[1]) > _angle(a[0], a[1])) a[1] = b[1];
        if (_angle(b[0], a[1]) > _angle(a[0], a[1])) a[0] = b[0];
      } else {
        merged.add(a = b);
      }
    }

    // Finally, find the largest gap between the merged ranges.
    // The final bounding box will be the inverse of this gap.
    deltaMax = double.negativeInfinity;
    n = merged.length - 1;
    a = merged[n];
    for ((i = 0); i <= n; a = b, ++i) {
      b = merged[i];
      if ((delta = _angle(a[1], b[0])) > deltaMax) {
        deltaMax = delta;
        _lambda0 = b[0];
        _lambda1 = a[1];
      }
    }
  }

  _ranges = _range = null;

  return _lambda0 == double.infinity || _phi0 == double.infinity
      ? [
          [double.nan, double.nan],
          [double.nan, double.nan]
        ]
      : [
          [_lambda0, _phi0],
          [_lambda1, _phi1]
        ];
}
