import 'projection/projection.dart';

/// Raw transforms are point transformation functions that are used to implement
/// custom projections.
///
/// They typically passed to [GeoProjection] or [GeoProjectionMutator]. They are
/// exposed here to facilitate the derivation of related projections. Raw
/// transforms take spherical coordinates \[*lambda*, *phi*\] in radians (not
/// degrees!) and return a point \[*x*, *y*\], typically in the unit square
/// centered around the origin.
class GeoRawTransform {
  /// Transforms the specified point \[*lambda*, *phi*\] in radians, returning a
  /// new point \[*x*, *y*\] in unspecified and implementation-dependent
  /// coordinates.
  final List<num> Function(List<num>) forward;

  /// The inverse of [forward].
  final List<num> Function(List<num>)? backward;

  const GeoRawTransform(this.forward, [this.backward]);
}
