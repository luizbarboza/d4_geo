import 'adder.dart';
import 'cartesian.dart';
import 'math.dart';

num _longitude(List<num> point) => abs(point[0]) <= pi
    ? point[0]
    : sign(point[0]) * ((abs(point[0]) + pi) % tau - pi);

bool polygonContains(List<List<List<num>>> polygon, List<num> point) {
  var lambda = _longitude(point),
      phi = point[1],
      sinPhi = sin(phi),
      normal = [sin(lambda), -cos(lambda), 0.0],
      angle = 0.0,
      winding = 0;

  var sum = Adder();

  if (sinPhi == 1) {
    phi = halfPi + epsilon;
  } else if (sinPhi == -1) {
    phi = -halfPi - epsilon;
  }

  for (var i = 0, n = polygon.length; i < n; ++i) {
    List<List<num>> ring;
    int m;
    if ((m = (ring = polygon[i]).length) == 0) continue;
    var point0 = ring[m - 1],
        lambda0 = _longitude(point0),
        phi0 = point0[1] / 2 + quarterPi,
        sinPhi0 = sin(phi0),
        cosPhi0 = cos(phi0);
    late List<num> point1;
    late num lambda1;
    late double phi1, sinPhi1, cosPhi1;

    for (var j = 0;
        j < m;
        ++j,
        lambda0 = lambda1,
        sinPhi0 = sinPhi1,
        cosPhi0 = cosPhi1,
        point0 = point1) {
      point1 = ring[j];
      lambda1 = _longitude(point1);
      phi1 = point1[1] / 2 + quarterPi;
      sinPhi1 = sin(phi1);
      cosPhi1 = cos(phi1);
      var delta = lambda1 - lambda0,
          sign = delta >= 0 ? 1 : -1,
          absDelta = sign * delta,
          antimeridian = absDelta > pi,
          k = sinPhi0 * sinPhi1;

      sum.add(atan2(
          k * sign * sin(absDelta), cosPhi0 * cosPhi1 + k * cos(absDelta)));
      angle += antimeridian ? delta + sign * tau : delta;

      // Are the longitudes either side of the point’s meridian (lambda),
      // and are the latitudes smaller than the parallel (phi)?
      if (antimeridian ^ (lambda0 >= lambda) ^ (lambda1 >= lambda)) {
        var arc = cartesianCross(cartesian(point0), cartesian(point1));
        cartesianNormalizeInPlace(arc);
        var intersection = cartesianCross(normal, arc);
        cartesianNormalizeInPlace(intersection);
        var phiArc =
            (antimeridian ^ (delta >= 0) ? -1 : 1) * asin(intersection[2]);
        if (phi > phiArc || phi == phiArc && (arc[0] != 0 || arc[1] != 0)) {
          winding += antimeridian ^ (delta >= 0) ? 1 : -1;
        }
      }
    }
  }

  // First, determine whether the South pole is inside or outside:
  //
  // It is inside if:
  // * the polygon winds around it in a clockwise direction.
  // * the polygon does not (cumulatively) wind around it, but has a negative
  //   (counter-clockwise) area.
  //
  // Second, count the (signed) number of times a segment crosses a lambda
  // from the point to the South pole.  If it is zero, then the point is the
  // same side as the South pole.

  return (angle < -epsilon || angle < epsilon && sum.valueOf() < -epsilon2) ^
      winding.isOdd;
}
