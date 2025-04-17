A high-level Flutter plugin for working with the [Lab Streaming Layer (LSL)](https://github.com/sccn/labstreaminglayer), designed to make real-time data streaming easy and accessible in Flutter apps.

This package wraps the low-level [`lsl_ffi`](https://pub.dev/packages/lsl_ffi) bindings to provide a simplified and idiomatic Flutter/Dart API for developers who want to stream or record physiological signals (like EEG, EMG, ECG), behavioral data, or any custom time-series streams using LSL.

## ✨ Features

- Discover LSL streams on the local network
- Resolve streams by properties (e.g., name, type)
- Push samples/chunks via LSL outlets
- Pull samples/chunks via LSL inlets
- Optional automatic clock synchronization
- Cross-platform (macOS, Windows, Android, iOS)

Powered by native bindings via [`lsl_ffi`](https://pub.dev/packages/lsl_ffi) and made user-friendly for Flutter developers.

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  | ⚠️ \* | ❌  |  ❓   |   ❓    |

\* For production grade development special permission is required from Apple to use multicast capabilities that has not been tested. [macOS](macos) However, if not meant for distribution on App Store, un-sandboxing the Mac app will allow multicast usage.

## 🚀 Getting started

Before using `lsl_flutter`, ensure:

- You are targeting a platform supported by both Flutter and LSL (i.e., not web).
- For mobile, you may need to include the LSL native libraries in your project’s platform folders.

Install via `pubspec.yaml`:

```yaml
dependencies:
  lsl_flutter: ^1.0.0
```

### Android

The minimum SDK version must be set to 26 in `app/build.gradle`. This is due to the logging library used by LSL, Loguru.

```java
// app/build.gradle
minSdk = 26
```

Although not due to this plugin, users may encounter the problem mentioned [here](https://github.com/flutter/flutter-intellij/issues/7152#issuecomment-2132853632) when creating a new project for Android. To avoid, make the following change in your `settings.gradle` file:

```diff
- includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
+ includeBuild(file("$flutterSdkPath/packages/flutter_tools/gradle").toPath().toRealPath().toAbsolutePath().toString())
```

The `AndroidManifest.xml` must contain

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

### iOS

### macOS

### Windows

## 📦 Usage

The package facilitates various levels of abstraction.

The package exposes three manager classes, one for _inlets_, one fore _outlets_ and one for _stream_ discovery and creation. Creating an outlet and pushing a sample can be achieved in the following way:

```dart
// Create a stream information object for PPG data that will have integer samples, 4 channels,
// and a nominal sampling rate of 135 Hz
final streamInfo = StreamInfoFactory.createIntStreamInfo(
    name, "PPG", Int64ChannelFormat(),
    channelCount: 4, nominalSRate: 135, sourceId: deviceId);

// Create an outlet manager with the stream information, this furthermore opens the outlet
// Optional parameters are `outletChunkSize` (default 0) and `outletMaxBuffered ` (default 360)
final manager = OutletManager(streamInfo);

manager.pushSample([1, 2, 3, 4]);
```

To discover streams a resolver can be created

```dart
// Create a stream manager
final streamManager = StreamManager();

// Resolve the available streams on the network
final resolvedStreams = streamManager.resolve();

// Create an inlet to the first found stream
final inletManager = streamManager.createInlet(resolvedStreams[0]);

// Pull the next available sample from the stream
final sample = inletManager.pullsSample();
```

For convenience a Dart stream can be created on the inlet manager that emits available samples based on the nominal sampling rate of the LSL stream.

```dart
// Start a sample stream and listen
final subscription = inletManager.startSampleStream().listen((sample) {
  log("Sample: ${sample.$1}");
  log("Timestamp: ${sample.$2}");
});
```

<!--
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
