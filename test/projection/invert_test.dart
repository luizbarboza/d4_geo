import 'package:d4_geo/d4_geo.dart';
import 'package:test/test.dart';

import 'projection_equal.dart';

void main() {
  test("projection.forward(point) and projection.backward(point) are symmetric",
      () {
    final factories = [
      geoAlbers,
      geoAzimuthalEqualArea,
      geoAzimuthalEquidistant,
      geoConicConformal,
      () => geoConicConformal()..parallels = [20, 30],
      () => geoConicConformal()..parallels = [30, 30],
      () => geoConicConformal()..parallels = [-35, -50],
      () => geoConicConformal()
        ..parallels = [40, 60]
        ..rotate = [-120, 0],
      geoConicEqualArea,
      () => geoConicEqualArea()..parallels = [20, 30],
      () => geoConicEqualArea()..parallels = [-30, 30],
      () => geoConicEqualArea()..parallels = [-35, -50],
      () => geoConicEqualArea()
        ..parallels = [40, 60]
        ..rotate = [-120, 0],
      geoConicEquidistant,
      () => geoConicEquidistant()..parallels = [20, 30],
      () => geoConicEquidistant()..parallels = [30, 30],
      () => geoConicEquidistant()..parallels = [-35, -50],
      () => geoConicEquidistant()
        ..parallels = [40, 60]
        ..rotate = [-120, 0],
      geoEquirectangular,
      geoEqualEarth,
      geoGnomonic,
      geoMercator,
      geoOrthographic,
      geoStereographic,
      GeoTransverseMercator.new
    ];

    final points = [
      [0, 0],
      [30.3, 24.1],
      [-10, 42],
      [-2, -5]
    ];

    expect(
        factories.map((f) {
          final projection = f();
          return points.map((p) => [p, projection.call(p)]).toList();
        }).toList(),
        factories.map((f) {
          final projectionEqual = ProjectionEqual(f());
          return List.filled(points.length, projectionEqual);
        }).toList());

    final projection = GeoAlbersUsa();

    var points2 = [
      [-122.4194, 37.7749],
      [-74.0059, 40.7128],
      [-149.9003, 61.2181],
      [-157.8583, 21.3069]
    ];

    expect(points2.map((p) => [p, projection.call(p)]).toList(),
        List.filled(points2.length, ProjectionEqual(projection)));
  });
}
