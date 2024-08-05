import 'package:d4_path/d4_path.dart';

class TestContext implements Path {
  var buffer = <Map>[];

  @override
  moveTo(x, y) =>
      buffer.add({"type": "moveTo", "x": x.round(), "y": y.round()});

  @override
  lineTo(x, y) =>
      buffer.add({"type": "lineTo", "x": x.round(), "y": y.round()});

  @override
  arc(x, y, r, _, __, [___ = false]) =>
      buffer.add({"type": "arc", "x": x.round(), "y": y.round(), "r": r});

  @override
  closePath() => buffer.add({"type": "closePath"});

  List<Map> result() {
    var result = buffer;
    buffer = [];
    return result;
  }

  @override
  void arcTo(x1, y1, x2, y2, radius) => throw UnimplementedError();

  @override
  void bezierCurveTo(cpx1, cpy1, cpx2, cpy2, x, y) =>
      throw UnimplementedError();

  @override
  void quadraticCurveTo(cpx, cpy, x, y) => throw UnimplementedError();

  @override
  void rect(x, y, w, h) => throw UnimplementedError();
}
