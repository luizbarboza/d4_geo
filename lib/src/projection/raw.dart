import 'projection.dart';

// ignore: prefer_void_to_null
Null constNull(_, __, [___]) {}

/// Raw projections are point transformation functions that are used to
/// implement custom projections.
///
/// They typically passed to [GeoProjection] or [GeoProjectionMutator]. They are
/// exposed here to facilitate the derivation of related projections. Raw
/// transforms take spherical coordinates \[*lambda*, *phi*\] in radians (not
/// degrees!) and return a point \[*x*, *y*\], typically in the unit square
/// centered around the origin.
///
/// {@category Projections}
class GeoRawProjection {
  final List<num> Function(num, num) _raw;
  final List<num>? Function(num, num) _invert;

  const GeoRawProjection(List<num> Function(num, num) transform,
      [List<num>? Function(num, num)? invert])
      : _raw = transform,
        _invert = invert ?? constNull;

  /// Transforms the specified point \[[lambda], [phi]\] in radians, returning a
  /// new point \[*x*, *y*\] in unspecified and implementation-dependent
  /// coordinates.
  List<num> call(num lambda, num phi) => _raw(lambda, phi);

  /// The inverse of [call].
  List<num>? invert(num x, num y) => _invert(x, y);
}

extension InternGeoRawProjection on GeoRawProjection {
  List<num> Function(num, num) get project => _raw;
  List<num>? Function(num, num) get projectInvert => _invert;
}
