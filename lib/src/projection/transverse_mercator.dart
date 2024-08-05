import '../math.dart';
import 'raw.dart';
import 'mercator.dart';
import 'projection.dart';

List<num> _transverseMercatorRaw(num lambda, num phi, [_]) =>
    [log(tan((halfPi + phi) / 2)), -lambda];

List<num> _transverseMercatorInvert(num x, num y, [_]) =>
    [-y, 2 * atan(exp(x)) - halfPi];

/// The raw transverse spherical Mercator projection.
///
/// {@category Projections}
/// {@category Cylindrical projections}
const geoTransverseMercatorRaw =
    GeoRawProjection(_transverseMercatorRaw, _transverseMercatorInvert);

/// The transverse spherical Mercator projection.
///
/// Defines a default [GeoProjection.clipExtent] such that the world is
/// projected to a square, clipped to approximately ±85° latitude.
///
/// {@category Projections}
/// {@category Cylindrical projections}
class GeoTransverseMercator extends MercatorProjection {
  GeoTransverseMercator() : super(geoTransverseMercatorRaw) {
    super.rotate = [0, 0, 90];
    scale = 159.155;
  }

  @override
  set center(List<double> center) {
    super.center = [-center[1], center[0]];
  }

  @override
  get center {
    var c = super.center;
    return [c[1], -c[0]];
  }

  @override
  set rotate(List<double> rotate) {
    super.rotate = [
      rotate[0],
      rotate[1],
      if (rotate.length > 2) rotate[2] + 90 else 90
    ];
  }

  @override
  get rotate {
    var r = super.rotate;
    return [r[0], r[1], r[2] - 90];
  }
}
