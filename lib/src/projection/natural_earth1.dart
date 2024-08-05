import '../math.dart';
import 'raw.dart';
import 'projection.dart';

List<double> _naturalEarth1Raw(num lambda, num phi, [_]) {
  var phi2 = phi * phi, phi4 = phi2 * phi2;
  return [
    lambda *
        (0.8707 -
            0.131979 * phi2 +
            phi4 * (-0.013791 + phi4 * (0.003971 * phi2 - 0.001529 * phi4))),
    phi *
        (1.007226 +
            phi2 *
                (0.015085 +
                    phi4 * (-0.044475 + 0.028874 * phi2 - 0.005916 * phi4)))
  ];
}

List<num> _naturalEarth1Invert(num x, num y, [_]) {
  var phi = y, i = 25;
  double delta;
  num phi2, phi4;
  do {
    phi2 = phi * phi;
    phi4 = phi2 * phi2;
    phi -= delta = (phi *
                (1.007226 +
                    phi2 *
                        (0.015085 +
                            phi4 *
                                (-0.044475 +
                                    0.028874 * phi2 -
                                    0.005916 * phi4))) -
            y) /
        (1.007226 +
            phi2 *
                (0.015085 * 3 +
                    phi4 *
                        (-0.044475 * 7 +
                            0.028874 * 9 * phi2 -
                            0.005916 * 11 * phi4)));
  } while (abs(delta) > epsilon && --i > 0);
  return [
    x /
        (0.8707 +
            (phi2 = phi * phi) *
                (-0.131979 +
                    phi2 *
                        (-0.013791 +
                            phi2 *
                                phi2 *
                                phi2 *
                                (0.003971 - 0.001529 * phi2)))),
    phi
  ];
}

/// The raw [Natural Earth projection](http://www.shadedrelief.com/NE_proj/).
///
/// {@category Projections}
/// {@category Cylindrical projections}
const geoNaturalEarth1Raw =
    GeoRawProjection(_naturalEarth1Raw, _naturalEarth1Invert);

/// The [Natural Earth projection](http://www.shadedrelief.com/NE_proj/) is a
/// pseudocylindrical projection designed by Tom Patterson.
///
/// It is neither conformal nor equal-area, but appealing to the eye for
/// small-scale maps of the whole world.
///
/// {@category Projections}
/// {@category Cylindrical projections}
GeoProjection geoNaturalEarth1() =>
    GeoProjection(geoNaturalEarth1Raw)..scale = 175.295;
