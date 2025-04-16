# muse_sdk

This is a Flutter plugin wrapping the SDKs provided by Muse.
At the moment only Android is supported partially.

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ⚠️    | ❌  |  ❌   | ❌  |  ❌   |   ❌    |

## Usage

As stated in the disclaimer, the Muse SDK is not included as per its license. So in order to use this plugin, users must have access to the SDK and place them in the correct directories.

### Android

The `libmuse_android.jar` must be placed in `android/libs`

The `x86_64`, `x86`, `arm64-v8a` `armeabi-v7a` folders muse be placed under `android/src/main/jniLibs`

Furthermore the `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN` permissions must be explicitly granted by users, e.g. using the `permission_handler` plugin.

## Disclaimer

This Flutter plugin references the Muse SDK, which is not included in this repository due to licensing restrictions. To use this plugin, you must obtain the Muse SDK directly from Interaxon and place it in the appropriate location as specified in the installation instructions.

All references to Muse SDK APIs are used under the terms of the SDK license agreement. This project does not distribute, expose, or modify the Muse SDK or any of its contents.
