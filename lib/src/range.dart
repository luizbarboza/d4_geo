List<double> range({double start = 0, required double stop, double step = 1}) {
  var n = ((stop - start) / step).ceilToDouble();

  if (!n.isFinite || n.isNegative) n = 0;

  return List.generate(n.truncate(), (i) => (start + i * step),
      growable: false);
}
