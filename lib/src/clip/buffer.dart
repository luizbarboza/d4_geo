import '../stream.dart';

class Buffer extends GeoStream {
  List<List<List<num>>> _lines = [];
  List<List<num>>? _line;

  Buffer() {
    point = (x, y, [m]) {
      _line!.add([x, y, if (m != null) m]);
    };
    lineStart = () {
      _lines.add(_line = []);
    };
  }

  void rejoin() {
    if (_lines.length > 1) {
      _lines.add([..._lines.removeLast(), ..._lines.removeAt(0)]);
    }
  }

  List<List<List<num>>> result() {
    var result = _lines;
    _lines = [];
    _line = null;
    return result;
  }
}
