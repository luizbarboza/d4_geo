int _compareIgnoreNaN(num a, num b) => a.isNaN || b.isNaN ? -1 : a.compareTo(b);

int _defaultCompare(Object? value1, Object? value2) =>
    (value1 as Comparable<Object?>).compareTo(value2);

List<S?> extent<S>(Iterable<S> values, {int Function(S, S)? compare}) {
  compare ??=
      S == num ? _compareIgnoreNaN as int Function(S, S) : _defaultCompare;

  S? min, max;
  for (final value in values) {
    if (value != null) {
      if (min == null) {
        if (compare(value, value) >= 0) min = max = value;
      } else {
        if (compare(min, value) > 0) min = value;
        // ignore: null_check_on_nullable_type_parameter
        if (compare(value, max!) > 0) max = value;
      }
    }
  }
  return [min, max];
}

List<T?> extentBy<S, T>(
    Iterable<S?> values, T? Function(S?, int, Iterable<S?>) orderBy,
    {int Function(T, T)? compare}) {
  compare ??=
      T == num ? _compareIgnoreNaN as int Function(T, T) : _defaultCompare;

  T? min, max;
  var index = -1;
  for (final value in values) {
    final valueOrderBy = orderBy(value, ++index, values);
    if (valueOrderBy != null) {
      if (min == null) {
        if (compare(valueOrderBy, valueOrderBy) >= 0) min = max = valueOrderBy;
      } else {
        if (compare(min, valueOrderBy) > 0) min = valueOrderBy;
        // ignore: null_check_on_nullable_type_parameter
        if (compare(valueOrderBy, max!) > 0) max = valueOrderBy;
      }
    }
  }
  return [min, max];
}
