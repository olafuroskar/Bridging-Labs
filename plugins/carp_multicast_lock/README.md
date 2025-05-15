````markdown
# Mutlicast Lock Plugin

A minimal Flutter plugin for acquiring and releasing the Android [WifiManager MulticastLock](https://developer.android.com/reference/android/net/wifi/WifiManager.MulticastLock). This is useful for apps that need to receive multicast packets, such as when using protocols like mDNS or Lab Streaming Layer (LSL).

> ⚠️ This plugin **only supports Android**. On other platforms, calls will have no effect.

## Features

- Acquire the Android multicast lock
- Release the multicast lock

## Getting started

Add this plugin to your `pubspec.yaml`:

```yaml
dependencies:
  multicast_lock: ^0.0.1
```
````

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:multicast_lock/multicast_lock.dart';

void enableMulticast() async {
  await MulticastLock.acquire();
}

void disableMulticast() async {
  await MulticastLock.release();
}
```

## Permissions

Make sure your app has `ACCESS_WIFI_STATE` and `CHANGE_WIFI_MULTICAST_STATE` permissions.

```xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

## License

[MIT](LICENSE)
