# LSL Bindings

Low-level Dart bindings to the [Lab Streaming Layer (LSL)](https://github.com/sccn/labstreaminglayer) C API.

This package provides direct access to the native LSL interface via Dart FFI and is intended for advanced users who require fine-grained control over streaming or receiving LSL data in Dart or Flutter applications.

If you're looking for a higher-level, idiomatic Flutter API for working with LSL, consider using [`lsl_flutter`](https://pub.dev/packages/lsl_flutter), which builds on top of this package.

## Features

- Direct Dart FFI bindings to the LSL C API
- Cross-platform support: macOS, iOS (via `.xcframework`), Windows, and Android

## Getting started

1. Add `dart:ffi` as a dependency, as it is needed for memory management and type conversion.

2. Add the plugin to your `pubspec.yaml` (or `flutter pub add lsl_bindings`):

```yaml
dev_dependencies:
  ffi: ^2.1.3
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

## Android

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

## iOS

Minimum deployment target must be set to at least 14

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'
```

The `Info.plist` for applications using the plugin must specify a reason for accessing the local network

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs local network access to discover data streams.</string>
```

## macOS

To develop an application that utilises UDP multicast, special permission is required from Apple. Therefore, when developing within a sandbox for macOS applications LSL will not be able to discovers streams on the network. So it is best to simply remove the sandbox from the app.

![image](https://github.com/user-attachments/assets/6ccc2e9c-485a-4b77-88c3-3b9a220314fc)
