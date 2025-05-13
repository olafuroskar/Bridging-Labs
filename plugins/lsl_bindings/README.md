Low-level Dart bindings to the [Lab Streaming Layer (LSL)](https://github.com/sccn/labstreaminglayer) C API, generated and maintained for use with Dart FFI.

This package is intended for advanced users who want fine-grained control over native LSL interop in their own Dart or Flutter applications.

If you're looking for a higher-level abstraction for streaming or receiving LSL data in Flutter, consider using [`lsl_flutter`](https://pub.dev/packages/lsl_flutter), which builds on top of these bindings.

## Features

- Direct access to LSL’s C API through Dart FFI
- Cross-platform support: macOS, iOS (via `.xcframework`), Windows, and Android

## Getting started

1. Add `dart:ffi` as a dependency, as it is needed for memory management and type conversion.

2. Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  lsl_bindings: ^1.0.0
```

## Usage

```dart
import 'package:lsl_bindings/lsl_bindings.dart';

final streamInfo = lslBindings.lsl_create_streaminfo(
  "Test stream".toNativeUtf8().cast<Char>(),
  "EEG".toNativeUtf8().cast<Char>(),
  4,
  256,
  lsl_channel_format_t.cft_double64,
  "Source id".toNativeUtf8().cast<Char>());
```

## iOS

Minimum deployment target must be set to at least 14

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'
```

## macOS

To develop an application that utilises UDP multicast, special permission is required from Apple. Therefore, when developing within a sandbox for macOS applications LSL will not be able to discovers streams on the network. So it is best to simply remove the sandbox from the app.

![image](https://github.com/user-attachments/assets/bc86af93-0f37-4215-9cc9-64264c955dc1)

<!--
# lsl_bindings

A new Flutter FFI plugin project.

## Getting Started

This project is a starting point for a Flutter
[FFI plugin](https://flutter.dev/to/ffi-package),
a specialized package that includes native code directly invoked with Dart FFI.

## Project structure

This template uses the following structure:

* `src`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library.

* `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.

* platform folders (`android`, `ios`, `windows`, etc.): Contains the build files
  for building and bundling the native code library with the platform application.

## Building and bundling native code

The `pubspec.yaml` specifies FFI plugins as follows:

```yaml
  plugin:
    platforms:
      some_platform:
        ffiPlugin: true
````

This configuration invokes the native build for the various target platforms
and bundles the binaries in Flutter applications using these FFI plugins.

This can be combined with dartPluginClass, such as when FFI is used for the
implementation of one platform in a federated plugin:

```yaml
plugin:
  implements: some_other_plugin
  platforms:
    some_platform:
      dartPluginClass: SomeClass
      ffiPlugin: true
```

A plugin can have both FFI and method channels:

```yaml
plugin:
  platforms:
    some_platform:
      pluginClass: SomeName
      ffiPlugin: true
```

The native build systems that are invoked by FFI (and method channel) plugins are:

- For Android: Gradle, which invokes the Android NDK for native builds.
  - See the documentation in android/build.gradle.
- For iOS and MacOS: Xcode, via CocoaPods.
  - See the documentation in ios/lsl_bindings.podspec.
  - See the documentation in macos/lsl_bindings.podspec.
- For Linux and Windows: CMake.
  - See the documentation in linux/CMakeLists.txt.
  - See the documentation in windows/CMakeLists.txt.

## Binding to native code

To use the native code, bindings in Dart are needed.
To avoid writing these by hand, they are generated from the header file
(`src/lsl_bindings.h`) by `package:ffigen`.
Regenerate the bindings by running `dart run ffigen --config ffigen.yaml`.

## Invoking native code

Very short-running native functions can be directly invoked from any isolate.
For example, see `sum` in `lib/lsl_bindings.dart`.

Longer-running functions should be invoked on a helper isolate to avoid
dropping frames in Flutter applications.
For example, see `sumAsync` in `lib/lsl_bindings.dart`.

## Flutter help

For help getting started with Flutter, view our
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
-->
