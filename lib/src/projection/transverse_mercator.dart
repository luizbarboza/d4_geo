import '../math.dart';
import '../raw.dart';
import 'mercator.dart';
import 'projection.dart';

List<num> _forward(List<num> p) => [log(tan((halfPi + p[1]) / 2)), -p[0]];

List<num> _backward(List<num> p) => [-p[1], 2 * atan(exp(p[0])) - halfPi];

/// The raw transverse spherical Mercator projection.
const geoTransverseMercatorRaw = GeoRawTransform(_forward, _backward);

/// The transverse spherical Mercator projection.
///
/// Defines a default [GeoProjection.clipExtent] such that the world is
/// projected to a square, clipped to approximately ±85° latitude.
class GeoTransverseMercator extends MercatorProjection {
  GeoTransverseMercator() : super(geoTransverseMercatorRaw) {
    super.rotate = [0, 0, 90];
    scale = 159.155;
  }

  @override
  set center(List<double> _) {
    super.center = [-_[1], _[0]];
  }

  @override
  get center {
    var _ = super.center;
    return [_[1], -_[0]];
  }

  @override
  set rotate(List<double> _) {
    super.rotate = [_[0], _[1], if (_.length > 2) _[2] + 90 else 90];
  }

  @override
  get rotate {
    var _ = super.rotate;
    return [_[0], _[1], _[2] - 90];
  }
}
