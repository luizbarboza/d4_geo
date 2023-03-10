import 'math.dart';

bool pointEqual(List<num> a, List<num> b) =>
    abs(a[0] - b[0]) < epsilon && abs(a[1] - b[1]) < epsilon;
