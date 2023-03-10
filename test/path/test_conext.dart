import 'package:d4_geo/src/path/context.dart';

GeoPathContext testContext() {
  var buffer = <Map>[];
  return GeoPathContext(
      (x, y) => buffer.add({"type": "moveTo", "x": x.round(), "y": y.round()}),
      (x, y) => buffer.add({"type": "lineTo", "x": x.round(), "y": y.round()}),
      (x, y, r, _, __) =>
          buffer.add({"type": "arc", "x": x.round(), "y": y.round(), "r": r}),
      () => buffer.add({"type": "closePath"}), () {
    var result = buffer;
    buffer = [];
    return result;
  });
}
