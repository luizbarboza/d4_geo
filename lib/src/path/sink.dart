import '../stream.dart';

abstract class GeoPathSink extends GeoStream {
  void pointRadius(double radius);
  String? result();
}
