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

The `AndroidManifest.xml` must contain

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

Also note, that in conjunction with the multicast permission specified above, a multicast lock must be acquired to make streams _from_ Android devices discoverable. This is due to the fact that Android devices, by default, do not accept multicast packet traffic. [carp_multicast_lock](rttps://pub.dev/packages/carp_multicast_lock) is for example used in the more opinionated [lsl_flutter](rttps://pub.dev/packages/lsl_flutter) package.

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

Furthermore, the entitlement `com.apple.developer.networking.multicast` must be applied for from Apple with a justification in order to discover streams on iOS devices. This can take several working days.

`Runner*.entitlements` must therefore include the following

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <!--...-->
    <key>com.apple.developer.networking.multicast</key>
    <true />
    <!--...-->
  </dict>
</plist>

```

## macOS

The same entitlement as in [iOS](#iOS) must be granted or the app can be de-sandboxed as illustrated in the image below.

![image](https://github.com/user-attachments/assets/6ccc2e9c-485a-4b77-88c3-3b9a220314fc)
