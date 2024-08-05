import 'math.dart';
import 'range.dart';

List<List<double>> Function(double) _graticuleX(
    double y0, double y1, double dy) {
  var y = range(start: y0, stop: y1 - epsilon, step: dy) + ([y1]);
  return (x) => y.map((y) => [x, y]).toList();
}

List<List<double>> Function(double) _graticuleY(
    double x0, double x1, double dx) {
  var x = range(start: x0, stop: x1 - epsilon, step: dx) + ([x1]);
  return (y) => x.map((x) => [x, y]).toList();
}

/// A geometry geographic generator for creating graticules.
///
/// {@category Spherical shapes}
class GeoGraticule {
  late double _x1 = 180,
      _x0 = -_x1,
      __x1 = _x1,
      __x0 = _x0,
      _y1 = 80 + epsilon,
      _y0 = -_y1,
      __y1 = 90 - epsilon,
      __y0 = -__y1,
      _dx = 10,
      _dy = _dx,
      __dx = 90,
      __dy = 360,
      _precision = 2.5;
  late List<List<double>> Function(double) _x, _y, __x, __y;

  /// Constructs a geometry generator for creating graticules: a uniform grid of
  /// [meridians](https://en.wikipedia.org/wiki/Meridian_(geography)) and
  /// [parallels](https://en.wikipedia.org/wiki/Circle_of_latitude) for showing
  /// projection distortion.
  ///
  /// The default graticule has meridians and parallels every 10° between ±80°
  /// latitude; for the polar regions, there are meridians every 90°.
  GeoGraticule() {
    precision = _precision;
  }

  /// Returns a GeoJSON MultiLineString geometry object representing all
  /// meridians and parallels for this graticule.
  Map call() => {"type": "MultiLineString", "coordinates": _lines()};

  List<List<List<double>>> _lines() => range(
          start: (__x0 / __dx).ceilToDouble() * __dx, stop: __x1, step: __dx)
      .map(__x)
      .followedBy(range(
              start: (__y0 / __dy).ceilToDouble() * __dy,
              stop: __y1,
              step: __dy)
          .map(__y))
      .followedBy(
          range(start: (_x0 / _dx).ceilToDouble() * _dx, stop: _x1, step: _dx)
              .where((x) => abs(x % __dx) > epsilon)
              .map(_x))
      .followedBy(
          range(start: (_y0 / _dy).ceilToDouble() * _dy, stop: _y1, step: _dy)
              .where((y) => abs(y % __dy) > epsilon)
              .map(_y))
      .toList();

  /// An array of GeoJSON LineString geometry objects, one for each meridian or
  /// parallel for this graticule.
  List<Map> get lines => _lines()
      .map((coordinates) => {"type": "LineString", "coordinates": coordinates})
      .toList();

  /// A GeoJSON Polygon geometry object representing the outline of this
  /// graticule, i.e. along the meridians and parallels defining its extent.
  Map get outline => {
        "type": "Polygon",
        "coordinates": [
          __x(__x0).followedBy([
            ...__y(__y1).skip(1),
            ...__x(__x1).toList().reversed.skip(1),
            ...__y(__y0).toList().reversed.skip(1)
          ]).toList()
        ]
      };

  /// The major and minor extents.
  ///
  /// Sets both [extentMajor] and [extentMinor] to the same value, but is read
  /// as [extentMinor] only.
  List<List<double>> get extent => extentMinor;
  set extent(List<List<double>> extent) {
    extentMajor = extent;
    extentMinor = extent;
  }

  /// The major extent.
  ///
  /// Defaults to ⟨⟨-180°, -90° + ε⟩, ⟨180°, 90° - ε⟩⟩.
  List<List<double>> get extentMajor => [
        [__x0, __y0],
        [__x1, __y1]
      ];
  set extentMajor(List<List<double>> extent) {
    __x0 = extent[0][0];
    __x1 = extent[1][0];
    __y0 = extent[0][1];
    __y1 = extent[1][1];
    if (__x0 > __x1) {
      var temp = __x0;
      __x0 = __x1;
      __x1 = temp;
    }
    if (__y0 > __y1) {
      var temp = __y0;
      __y0 = __y1;
      __y1 = temp;
    }
    precision = _precision;
  }

  /// The minor extent.
  ///
  /// Defaults to ⟨⟨-180°, -80° - ε⟩, ⟨180°, 80° + ε⟩⟩.
  List<List<double>> get extentMinor => [
        [_x0, _y0],
        [_x1, _y1]
      ];
  set extentMinor(List<List<double>> extent) {
    _x0 = extent[0][0];
    _x1 = extent[1][0];
    _y0 = extent[0][1];
    _y1 = extent[1][1];
    if (_x0 > _x1) {
      var temp = _x0;
      _x0 = _x1;
      _x1 = temp;
    }
    if (_y0 > _y1) {
      var temp = _y0;
      _y0 = _y1;
      _y1 = temp;
    }
    precision = _precision;
  }

  /// The major and minor step.
  ///
  /// Sets both [stepMajor] and [stepMinor] to the same value, but is read as
  /// [stepMinor] only.
  List<double> get step => stepMinor;
  set step(List<double> step) {
    stepMajor = step;
    stepMinor = step;
  }

  /// The major step.
  ///
  /// Defaults to ⟨90°, 360°⟩.
  List<double> get stepMajor => [__dx, __dy];
  set stepMajor(List<double> step) {
    __dx = step[0];
    __dy = step[1];
  }

  /// The minor step.
  ///
  /// Defaults to ⟨10°, 10°⟩.
  List<double> get stepMinor => [_dx, _dy];
  set stepMinor(List<double> step) {
    _dx = step[0];
    _dy = step[1];
  }

  /// The precision angle in degrees.
  ///
  /// Defaults to 25°.
  double get precision => _precision;
  set precision(double angle) {
    _precision = angle;
    _x = _graticuleX(_y0, _y1, 90);
    _y = _graticuleY(_x0, _x1, _precision);
    __x = _graticuleX(__y0, __y1, 90);
    __y = _graticuleY(__x0, __x1, _precision);
  }
}

/// A convenience method for directly generating the default 10° global
/// graticule as a GeoJSON MultiLineString geometry object.
///
/// Equivalent to:
///
/// ```dart
/// geoGraticule10() {
///   return GeoGraticule()();
/// }
/// ```
///
/// {@category Spherical shapes}
Map geoGraticule10() => GeoGraticule()();
