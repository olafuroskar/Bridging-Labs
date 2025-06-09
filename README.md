# Bridging Labs

This repository contains all necessary source code to build the `lsl_bindings` and `lsl_flutter` packages for the Lab Streaming Layer in Flutter.

- `plugins/` contains the most importantly the `lsl_plugin` plugin for Flutter, but may contain other plugins if needed in the future.
- `apps/` contains example apps using the `lsl_plugin`
- `apple/` contains the necessary files to build the `liblsl` library for Apple devices.

## `lsl_bindings`

For iOS and macOS `lsl_bindings` relies on a cross-platform framework generated from the `liblsl` source code. Furthermore, `install()` rules from the `CMakeLists.txt` make the Flutter build process fail on Windows. In both cases, slight modifications to the `CMakeLists.txt` in the `liblsl` source are needed. For maintainability `liblsl` is included as a submodule in this repository master, with scripts in the `scripts` folder that apply the needed patches to `liblsl` as well as copying the library to the correct place.

<!--

  // TODO: Add labels property on stream info: https://github.com/NeuropsyOL/RECORDA/blob/master/liblsl-Java/src/examples/HandleMetaData.java
  // https://github.com/NeuropsyOL/RECORDA/blob/09f68f48b73ad4936caa5cf937d6291b6e6efcb4/liblsl-Java/src/edu/ucsd/sccn/LSL.java#L292

This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
````

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
-->
