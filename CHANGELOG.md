## 2.0.0

### Removed

- `GeoPathContext` is no longer exposed.
- `GeoRawTransform` no longer exists.

### Added

- `GeoRawProjection` has been added to replace `GeoRawTransform`.

### Changed

- The type of the property `context` in `Path` has been changed from `GeoPathContext` to `Path` from the `d4_path` library.
- The `call` method in `GeoPath` now optionally also takes a dynamic argument list.
- The `pointRadius` property function in `GeoTransform` now optionally also takes a dynamic argument list.
- `GeoIdentity` now extends `GeoTransform` instead of `GeoProjection`.
- `GeoProjection` no longer extends `GeoRawTransform`.
- The `forward` and `backward` property functions in `GeoProjection` have been replaced by their equivalent methods `call` and `invert`, respectively.
- `GeoAlbersUsa` no longer extends `GeoRawTransform`.
- The `forward` and `backward` property functions in `GeoAlbersUsa` have been replaced by their equivalent methods `call` and `invert`, respectively.
- `GeoTransverseMercator` no longer extends `GeoRawTransform`.
- The `forward` and `backward` property functions in `GeoTransverseMercator` have been replaced by their equivalent methods `call` and `invert`, respectively.
- `GeoRotation` no longer extends `GeoRawTransform`
- The `forward` and `backward` property functions in `GeoRotation` have been replaced by their equivalent methods `call` and `invert`, respectively.
- The `call` method in `GeoTransform` has been renamed to `stream`.
- The `call` method in `GeoProjection` has been renamed to `stream`.
- The `call` method in `GeoAlbersUsa` has been renamed to `stream`.
- The `point` method in `GeoStream` now accepts `x`, `y`, and optionally `z` coordinates instead of a list of coordinates.
- The `point` property function in `GeoTransform` now accepts `x`, `y`, and optionally `z` coordinates instead of a list of coordinates.
- The `GeoProjectionMutator` class no longer takes a generic type parameter `T`.
- The `GeoProjectionMutator` constructor parameter `factory` now has a type that is a function optionally taking a dynamic argument list, rather than a function that takes a single argument of the generic type `T`.
- The `call` method in `GeoProjectionMutator` now optionally takes a list of dynamic arguments instead of a single argument of generic type `T`.
- The `GeoConicProjection` factory parameter `projectAt` now has a type that is a function optionally taking a dynamic argument list, rather than a function that takes a single argument of the generic type `T`. Additionally, the function's return type is now `GeoRawProjection` instead of `GeoRawTransform`.
- All raw projections are now of type `GeoRawProjection` instead of `GeoRawTransform`.

## 1.0.3

- Fixed a bug in the geoClipCircle function.

## 1.0.2

- Links in README.md must be secure to follow Dart file conventions. 1 link was insecure and have been updated.
- Added some badges to README.md.

## 1.0.1

- Formatting change to conform to Dart guidelines.

## 1.0.0

- Initial Release
