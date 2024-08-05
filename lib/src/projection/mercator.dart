import 'dart:math';

import '../math.dart';
import 'raw.dart';
import '../rotation.dart';
import 'projection.dart';

List<num> _mercatorRaw(num lambda, num phi, [_]) =>
    [lambda, log(tan((halfPi + phi) / 2))];

List<num> _mercatorInvert(num x, num y, [_]) => [x, 2 * atan(exp(y)) - halfPi];

/// The raw spherical Mercator projection.
///
/// {@category Projections}
/// {@category Cylindrical projections}
const geoMercatorRaw = GeoRawProjection(_mercatorRaw, _mercatorInvert);

/// The spherical Mercator projection.
///
/// Defines a default [GeoProjection.clipExtent] such that the world is
/// projected to a square, clipped to approximately ±85° latitude.
///
/// {@category Projections}
/// {@category Cylindrical projections}
GeoProjection geoMercator() =>
    MercatorProjection(geoMercatorRaw)..scale = 961 / tau;

class MercatorProjection extends GeoProjection {
  final GeoRawProjection _project;
  double? _x0, _y0, _x1, _y1; // clip extent

  MercatorProjection(this._project) : super(_project) {
    _reclip();
  }

  @override
  set scale(double scale) {
    super.scale = scale;
    _reclip();
  }

  @override
  set translate(List<double> translate) {
    super.translate = translate;
    _reclip();
  }

  @override
  set center(List<double> center) {
    super.center = center;
    _reclip();
  }

  @override
  set clipExtent(List<List<double>>? clipExtent) {
    if (clipExtent == null) {
      _x0 = _y0 = _x1 = _y1 = null;
    } else {
      _x0 = clipExtent[0][0];
      _y0 = clipExtent[0][1];
      _x1 = clipExtent[1][0];
      _y1 = clipExtent[1][1];
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
        t = call(GeoRotation([r[0], r[1], r[2]]).invert([0, 0])!);
    super.clipExtent = _x0 == null
        ? [
            [t![0] - k, t[1] - k],
            [t[0] + k, t[1] + k]
          ]
        : identical(_project, geoMercatorRaw)
            ? [
                [max(t![0] - k, _x0!), _y0!],
                [min(t[0] + k, _x1!), _y1!]
              ]
            : [
                [_x0!, max(t![1] - k, _y0!)],
                [_x1!, min(t[1] + k, _y1!)]
              ];
  }
}
