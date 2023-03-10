import 'math.dart';

List<double> spherical(List<double> cartesian) =>
    [atan2(cartesian[1], cartesian[0]), asin(cartesian[2])];

List<double> cartesian(List<num> spherical) {
  var lambda = spherical[0], phi = spherical[1], cosPhi = cos(phi);
  return [cosPhi * cos(lambda), cosPhi * sin(lambda), sin(phi)];
}

double cartesianDot(List<double> a, List<double> b) =>
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2];

List<double> cartesianCross(List<double> a, List<double> b) => [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0]
    ];

// TODO return a
void cartesianAddInPlace(List<double> a, List<double> b) {
  a[0] += b[0];
  a[1] += b[1];
  a[2] += b[2];
}

List<double> cartesianScale(List<double> vector, double k) =>
    [vector[0] * k, vector[1] * k, vector[2] * k];

// TODO return d
void cartesianNormalizeInPlace(List<num> d) {
  var l = sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]);
  d[0] /= l;
  d[1] /= l;
  d[2] /= l;
}
