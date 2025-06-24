# Testing

The standard `dart test` library is used for running the tests, and `mockito` is used to create mocks of classes that need to communicate with native code.

If the bindings for LSL in the plugin are updated then the following must be run to update the mocks:

```bash
dart run build_runner build
```
