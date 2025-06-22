# Bridging Labs

This repository contains all necessary source code to build the `lsl_bindings` and `lsl_flutter` packages for the Lab Streaming Layer in Flutter.

The repository has a submodule so when cloning use

```
git clone --recursive git@github.com:olafuroskar/Bridging-Labs.git

```

- `apps/` contains example apps using the `lsl_plugin`
- `apple/` contains the necessary files to build the `liblsl` library for Apple devices.
- `liblsl/` contains a submodule of [`liblsl`](https://github.com/sccn/liblsl)
- `patches/` contains the patches that can be applied to `liblsl` for enabling building on different platforms.
- `plugins/` contains the packages of the system, most importantly `lsl_bindings` and `lsl_flutter`, but also `carp_multicast_lock` and `muse_sdk`.
- `scripts/` contains scripts that facilitate applying patches and building `xcframeworks`.

## `lsl_bindings`

### Scripts and patches

For iOS and macOS `lsl_bindings` relies on a cross-platform framework generated from the `liblsl` source code. Furthermore, `install()` rules from the `CMakeLists.txt` make the Flutter build process fail on Windows. In both cases, slight modifications to the `CMakeLists.txt` in the `liblsl` source are needed. For maintainability `liblsl` is included as a submodule in this repository master, with scripts in the `scripts` folder that apply the needed patches to `liblsl` as well as copying the library to the correct place.

The following steps require `git`, `cmake` and the `xcode` CLI tools to be installed.

To regenerate the `xcframeworks` for the Apple platforms, simply run from the workspace root:

```
./scripts/lsl_apple.sh
```

This will:

- fetch the latest commits to master in `liblsl`,
- try to apply the needed patch in `patches/lsl_apple.patch`,
- copy the patched library to the `apple` directory,
- from the `apple` directory build the needed frameworks,
- and finally merge the frameworks into an `xcframework`.

In the same vein, in order to regenerate the library without any `install()` rules, simply run from the workspace root:

```
./scripts/lsl_add_skip_install.sh
```

This will:

- fetch the latest commits to master in `liblsl`,
- try to apply the needed patch in `patches/lsl_add_skip_install.patch`,
- and copy the patched library to the `plugins/lsl_bindings/src` directory.

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
