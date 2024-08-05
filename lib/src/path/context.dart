import 'package:d4_path/d4_path.dart';

import '../math.dart';
import 'sink.dart';

// Renders a path to a canvas using a subset of the CanvasRenderingContext2D
// API.
class GeoPathContext extends GeoPathSink {
  double _radius = 4.5;
  int _line = 1, _point = 2;

  Path context;

  GeoPathContext(this.context) {
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
      if (_line == 0) context.closePath();
      _point = 2;
    };
    point = (x, y, [_]) {
      switch (_point) {
        case 0:
          context.moveTo(x, y);
          _point = 1;
          break;
        case 1:
          context.lineTo(x, y);
          break;
        default:
          context.moveTo(x + _radius, y);
          context.arc(x, y, _radius, 0, tau);
      }
    };
  }

  @override
  pointRadius(radius) => _radius = radius;

  @override
  result() => null;
}
