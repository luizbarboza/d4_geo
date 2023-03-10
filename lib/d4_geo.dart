import 'src/projection/gnomonic.dart';

/// Geographic projections, spherical shapes and spherical trigonometry.
///
/// Map projections are sometimes implemented as point transformations. For
/// instance, spherical Mercator:
///
/// ```dart
/// mercator(num x, num y) => [x, log(tan(pi / 4 + y / 2))];
/// ```
///
/// This is a reasonable mathematical approach if your geometry consists of
/// continuous, infinite point sets. Yet computers do not have infinite memory,
/// so we must instead work with discrete geometry such as polygons and
/// polylines!
///
/// Discrete geometry makes the challenge of projecting from the sphere to the
/// plane much harder. The edges of a spherical polygon are
/// [geodesics](https://en.wikipedia.org/wiki/Geodesic) (segments of great
/// circles), not straight lines. Projected to the plane, geodesics are curves
/// in all map projections except [geoGnomonic], and thus accurate projection
/// requires interpolation along each arc. D3 uses
/// [adaptive sampling](https://observablehq.com/@d3/adaptive-sampling) inspired
/// by a popular
/// [line simplification method](https://bost.ocks.org/mike/simplify/) to
/// balance accuracy and performance.
///
/// The projection of polygons and polylines must also deal with the topological
/// differences between the sphere and the plane. Some projections require
/// cutting geometry that
/// [crosses the antimeridian](https://observablehq.com/@d3/antimeridian-cutting),
/// while others require
/// [clipping geometry to a great circle](https://observablehq.com/@d3/orthographic-shading).
///
/// Spherical polygons also require a
/// [winding order convention](https://observablehq.com/@d3/winding-order) to
/// determine which side of the polygon is the inside: the exterior ring for
/// polygons smaller than a hemisphere must be clockwise, while the exterior
/// ring for polygons
/// [larger than a hemisphere](https://observablehq.com/@d3/oceans) must be
/// anticlockwise. Interior rings representing holes must use the opposite
/// winding order of their exterior ring. This winding order convention is also
/// used by [TopoJSON](https://pub.dev/packages/topo) and
/// [ESRI shapefiles](https://github.com/mbostock/shapefile); however, it is the
/// opposite convention of GeoJSON’s
/// [RFC 7946](https://tools.ietf.org/html/rfc7946#section-3.1.6). (Also note
/// that standard GeoJSON WGS84 uses planar equirectangular coordinates, not
/// spherical coordinates, and thus may require
/// [stitching](https://github.com/d3/d3-geo-projection/blob/main/README.md#geostitch)
/// to remove antimeridian cuts.)
///
/// D3’s approach affords great expressiveness: you can choose the right
/// projection, and the right aspect, for your data. D3 supports a wide variety
/// of common and unusual map projections. For more, see Part 2 of
/// [The Toolmaker’s Guide](https://vimeo.com/106198518#t=20m0s).
///
/// D3 uses [GeoJSON](http://geojson.org/geojson-spec.html) to represent
/// geographic features in JavaScript. (See also
/// [TopoJSON](https://pub.dev/packages/topo), an extension of GeoJSON
/// that is significantly more compact and encodes topology.) To convert
/// shapefiles to GeoJSON, use
/// [shp2json](https://github.com/mbostock/shapefile/blob/main/README.md#shp2json),
/// part of the [shapefile package](https://github.com/mbostock/shapefile). See
/// [Command-Line Cartography](https://medium.com/@mbostock/command-line-cartography-part-1-897aa8f8ca2c)
/// for an introduction to d3-geo and related tools.
export 'src/d4_geo.dart';
