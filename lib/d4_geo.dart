/// Geographic projections, spherical shapes and spherical trigonometry.
///
/// Map projections are sometimes implemented as point transformations: a
/// function that takes a given longitude *lambda* and latitude *phi*, and
/// returns the corresponding *xy* position on the plane. For instance, here is
/// the spherical Mercator projection (in radians):
///
/// ```dart
/// num mercator(num lambda, num phi) {
///   final x = lambda;
///   final y = log(tan(pi / 4 + y / 2));
///   return [x, y];
/// }
/// ```
///
/// This is a reasonable approach if your geometry consists only of points. But
/// what about discrete geometry such as polygons and polylines?
///
/// Discrete geometry introduces new challenges when projecting from the sphere
/// to the plane. The edges of a spherical polygon are
/// [geodesics](https://en.wikipedia.org/wiki/Geodesic) (segments of great
/// circles), not straight lines. Geodesics become curves in all map projections
/// except
/// [gnomonic](https://pub.dev/documentation/d4_geo/latest/d4_geo/geoGnomonic.html),
/// and thus accurate projection requires interpolation along each arc. D4 uses
/// [adaptive sampling](https://observablehq.com/@d3/adaptive-sampling) inspired
/// by
/// [Visvalingam’s line simplification method](https://bost.ocks.org/mike/simplify/)
/// to balance accuracy and performance.
///
/// The projection of polygons and polylines must also deal with the topological
/// differences between the sphere and the plane. Some projections require
/// cutting geometry that
/// [crosses the antimeridian](https://observablehq.com/@d3/antimeridian-cutting),
/// while others require
/// [clipping geometry](https://observablehq.com/@d3/orthographic-shading) to a
/// great circle. Spherical polygons also require a
/// [winding order convention](https://observablehq.com/@d3/winding-order) to
/// determine which side of the polygon is the inside: the exterior ring for
/// polygons smaller than a hemisphere must be clockwise, while the exterior
/// ring for polygons
/// [larger than a hemisphere](https://observablehq.com/@d3/oceans) must be
/// anticlockwise. Interior rings representing holes must use the opposite
/// winding order of their exterior ring.
///
/// D4 uses spherical [GeoJSON](http://geojson.org/geojson-spec.html) to
/// represent geographic features in Dart. D4 supports a wide variety of
/// [common](https://pub.dev/documentation/d4_geo/latest/topics/Projections-topic.html)
/// and unusual map projections. And because D4 uses spherical geometry to
/// represent data, you can apply any aspect to any projection by rotating
/// geometry.
///
/// **TIP**: To convert shapefiles to GeoJSON, use the
/// [shapefile package](https://pub.dev/packages/shapefile).
///
/// **CAUTION**: D4’s winding order convention is also used by
/// [TopoJSON](https://github.com/topojson) and
/// [ESRI shapefiles](https://github.com/luizbarboza/shapefile); however, it is
/// the opposite convention of GeoJSON’s
/// [RFC 7946](https://tools.ietf.org/html/rfc7946#section-3.1.6). Also note
/// that standard GeoJSON WGS84 uses planar equirectangular coordinates, not
/// spherical coordinates, and thus may require stitching to remove antimeridian
/// cuts.
library;

export 'src/d4_geo.dart';
