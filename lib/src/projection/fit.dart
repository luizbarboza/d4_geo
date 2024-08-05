import '../math.dart';
import '../path/bounds.dart';

fit(projection, void Function(List<List<num>>) fitBounds, Map object,
    [bool ignoreClipExtent = true]) {
  var clip = ignoreClipExtent ? projection.clipExtent : null;
  projection
    ..scale = 150.0
    ..translate = [0.0, 0.0];
  if (clip != null) projection.clipExtent = null;
  fitBounds(bounds(object, projection.stream));
  if (clip != null) projection.clipExtent = clip;
  return projection;
}

extent(projection, List<List<double>> extent, Map object,
        [bool ignoreClipExtent = true]) =>
    fit(projection, (b) {
      var w = extent[1][0] - extent[0][0],
          h = extent[1][1] - extent[0][1],
          k = min(w / (b[1][0] - b[0][0]), h / (b[1][1] - b[0][1])),
          x = extent[0][0] + (w - k * (b[1][0] + b[0][0])) / 2,
          y = extent[0][1] + (h - k * (b[1][1] + b[0][1])) / 2;
      projection
        ..scale = 150 * k
        ..translate = [x, y];
    }, object, ignoreClipExtent);

size(projection, List<double> size, Map object,
        [bool ignoreClipExtent = true]) =>
    extent(
        projection,
        [
          [0, 0],
          size
        ],
        object,
        ignoreClipExtent);

width(projection, double width, Map object, [bool ignoreClipExtent = true]) =>
    fit(projection, (b) {
      var w = width,
          k = w / (b[1][0] - b[0][0]),
          x = (w - k * (b[1][0] + b[0][0])) / 2,
          y = -k * b[0][1];
      projection
        ..scale = 150 * k
        ..translate = [x, y];
    }, object, ignoreClipExtent);

height(projection, double height, Map object, [bool ignoreClipExtent = true]) =>
    fit(projection, (b) {
      var h = height,
          k = h / (b[1][1] - b[0][1]),
          x = -k * b[0][0],
          y = (h - k * (b[1][1] + b[0][1])) / 2;
      projection
        ..scale = 150 * k
        ..translate = [x, y];
    }, object, ignoreClipExtent);
