import 'dart:math';

import '../math.dart';
import '../raw.dart';
import '../rotation.dart';
import 'projection.dart';

List<num> _forward(List<num> p) => [p[0], log(tan((halfPi + p[1]) / 2))];

List<num> _backward(List<num> p) => [p[0], 2 * atan(exp(p[1])) - halfPi];

/// The raw spherical Mercator projection.
const geoMercatorRaw = GeoRawTransform(_forward, _backward);

/// The spherical Mercator projection.
///
/// Defines a default [GeoProjection.clipExtent] such that the world is
/// projected to a square, clipped to approximately ±85° latitude.
GeoProjection geoMercator() =>
    MercatorProjection(geoMercatorRaw)..scale = 961 / tau;

class MercatorProjection extends GeoProjection {
  final GeoRawTransform _project;
  double? _x0, _y0, _x1, _y1; // clip extent

  MercatorProjection(this._project) : super(_project) {
    _reclip();
  }

  @override
  set scale(double _) {
    super.scale = _;
    _reclip();
  }

  @override
  set translate(List<double> _) {
    super.translate = _;
    _reclip();
  }

  @override
  set center(List<double> _) {
    super.center = _;
    _reclip();
  }

  @override
  set clipExtent(List<List<double>>? _) {
    if (_ == null) {
      _x0 = _y0 = _x1 = _y1 = null;
    } else {
      _x0 = _[0][0];
      _y0 = _[0][1];
      _x1 = _[1][0];
      _y1 = _[1][1];
    }
    _reclip();
  }

  @override
  List<List<double>>? get clipExtent => _x0 == null
      ? null
      : [
          [_x0!, _y0!],
          [_x1!, _y1!]
        ];

  void _reclip() {
    var k = pi * scale,
        r = rotate,
        t = forward(GeoRotation([r[0], r[1], r[2]]).backward!([0, 0]));
    super.clipExtent = _x0 == null
        ? [
            [t[0] - k, t[1] - k],
            [t[0] + k, t[1] + k]
          ]
        : identical(_project, geoMercatorRaw)
            ? [
                [max(t[0] - k, _x0!), _y0!],
                [min(t[0] + k, _x1!), _y1!]
              ]
            : [
                [_x0!, max(t[1] - k, _y0!)],
                [_x1!, min(t[1] + k, _y1!)]
              ];
  }
}
