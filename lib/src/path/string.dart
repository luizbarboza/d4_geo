import 'sink.dart';

class GeoPathString extends GeoPathSink {
  double _radius = 4.5;
  late String _circle = _generateCircle(_radius);
  int _line = 1, _point = 2;

  List<String> _string = [];

  GeoPathString() {
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
      if (_line == 0) _string.add("Z");
      _point = 2;
    };
    point = (p) {
      var x = p[0], y = p[1];
      switch (_point) {
        case 0:
          _string.addAll(["M", x.toString(), ",", y.toString()]);
          _point = 1;
          break;
        case 1:
          _string.addAll(["L", x.toString(), ",", y.toString()]);
          break;
        default:
          _string.addAll(["M", x.toString(), ",", y.toString(), _circle]);
      }
    };
  }

  @override
  pointRadius(radius) {
    if (radius != _radius) {
      _radius = radius;
      _circle = _generateCircle(_radius);
    }
  }

  @override
  result() {
    if (_string.isNotEmpty) {
      var result = _string.join();
      _string = [];
      return result;
    } else {
      return null;
    }
  }
}

_generateCircle(double radius) =>
    "m0,${radius}a$radius,$radius 0 1,1 0,${-2 * radius}"
    "a$radius,$radius 0 1,1 0,${2 * radius}z";
