# lsl_plugin

A Flutter plugin for interacting with the Lab Streaming Layer. Allows users to create both LSL inlets and outlets on the local network.

Table of Contents
[Platform Support](pltform-support)
[Android](android)
[Requirements](req-android)
[Permissions](per-android)

[iOS](ios)
[Requirements](req-ios)
[Permissions](per-ios)

[macOS](macos)
[Requirements](req-macos)
[Permissions](per-macos)

[Windows](windows)
[Requirements](req-windows)
[Permissions](per-windows)

[Linux](linux)
[Requirements](req-linux)
[Permissions](per-linux)

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  | ⚠️ \* | ❌  |  ❓   |   ❓    |

\* Requires special permission from Apple that has not been tested. [macOS](macos)

## Android

### Requirements <a name="req-android"></a>

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

### Permissions <a name="per-android"></a>

The `AndroidManifest.xml` must contain

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

## iOS

### Requirements <a name="req-ios"></a>

### Permissions <a name="per-ios"></a>

## macOS

### Requirements <a name="req-macos"></a>

### Permissions <a name="per-macos"></a>

## Windows

### Requirements <a name="req-windows"></a>

### Permissions <a name="per-windows"></a>

## Linux

### Requirements <a name="req-linux"></a>

### Permissions <a name="per-linux"></a>
