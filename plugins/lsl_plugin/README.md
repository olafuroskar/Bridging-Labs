# lsl_plugin

A Flutter plugin for interacting with the Lab Streaming Layer. Allows users to create both LSL inlets and outlets on the local network.

## Table of Contents

1. [Platform Support](#platform-support)
2. [Android](#android)
3. [iOS](#ios)
4. [macOS](#macos)
5. [Windows](#windows)
6. [Linux](#linux)
7. [Examples](#example-usage)

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  | ⚠️ \* | ❌  |  ❓   |   ❓    |

\* Requires special permission from Apple that has not been tested. [macOS](macos)

## Android

### Requirements

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

### Permissions

The `AndroidManifest.xml` must contain

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

## iOS

### Requirements

### Permissions

## macOS

### Requirements

### Permissions

## Windows

### Requirements

### Permissions

## Linux

### Requirements

### Permissions

## Example Usage

### Outlets

### Inlets

The first step in creating inlets is to discover streams that exist on the network, or resolving them. This can be achieved with a `StreamManager`, which resolves existing streams on the network, keeps track of them for you and can instantiate an inlet from a chosen stream.

```dart
/// Creates a stream manager
StreamManager streamManager = StreamManager();

/// Resolve streams on the network with a timeout of 2 seconds
await streamManager.resolveStreams(2);

/// Gets a handle to all resolved stream that have an integer channel format
final intStreamHandles = streamManager.getIntStreamHandles();

/// Create an inlet manager from the first stream
final inletManager = streamManager.createInlet(intStreamHandles[0]);
```
