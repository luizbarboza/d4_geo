import 'conic_equal_area.dart';
import 'projection.dart';

/// The Albers’ equal area-conic projection.
///
/// This is a U.S.-centric configuration of [geoConicEqualArea].
GeoProjection geoAlbers() => geoConicEqualArea()
  ..parallels = [29.5, 45.5]
  ..scale = 1070
  ..translate = [480, 250]
  ..rotate = [96, 0]
  ..center = [-0.6, 38.7];
