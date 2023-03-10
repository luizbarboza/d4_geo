import 'raw.dart';

GeoRawTransform compose(GeoRawTransform a, GeoRawTransform b) =>
    GeoRawTransform(
        (p) => b.forward(a.forward(p)),
        a.backward != null && b.backward != null
            ? (p) => a.backward!(b.backward!(p))
            : null);
