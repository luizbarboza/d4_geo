import '../math.dart';
import '../noop.dart';
import 'sink.dart';

/// Renders a path to a canvas using a subset of the CanvasRenderingContext2D
/// API.
class GeoPathContext extends GeoPathSink {
  double _radius = 4.5;
  int _line = 1, _point = 2;

  final void Function(num, num) moveTo, lineTo;
  final void Function(num, num, num, num, num) arc;
  final void Function() closePath;
  final Object? Function() _result;

  GeoPathContext(this.moveTo, this.lineTo, this.arc, this.closePath,
      [Object? Function() result = noop])
      : _result = result {
    polygonStart = () {
      _line = 0;
    };
    polygonEnd = () {
      _line = 1;
    };
    lineStart = () {
      _point = 0;
    };
    lineEnd = () {
      if (_line == 0) closePath();
      _point = 2;
    };
    point = (p) {
      var x = p[0], y = p[1];
      switch (_point) {
        case 0:
          moveTo(x, y);
          _point = 1;
          break;
        case 1:
          lineTo(x, y);
          break;
        default:
          moveTo(x + _radius, y);
          arc(x, y, _radius, 0, tau);
      }
    };
  }

  @override
  pointRadius(radius) => _radius = radius;

  @override
  result() => _result();
}
