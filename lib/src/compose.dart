typedef MaybeBijective = (
  List<num> Function(num, num, [num?]),
  List<num>? Function(num, num, [num?])
);

MaybeBijective compose(MaybeBijective a, MaybeBijective b) => (
      (x, y, [_]) {
        final p = a.$1(x, y);
        return b.$1(p[0], p[1]);
      },
      (x, y, [_]) {
        final p = b.$2(x, y);
        return p != null ? a.$2(p[0], p[1]) : null;
      }
    );
