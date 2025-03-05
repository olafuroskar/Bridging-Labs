# Lab Streaming Layer for Apple

To enable the use of LSL on Apple devices, iOS more specifcally, certain steps must be taken to generate a suitable library to use. The flutter plugin `lsl_plugin` uses a so called `vendored_framework` to get the compiled code from which the Dart bindings used in the plugin are generated.

This document describes the steps to generate the `vendored_framework` for the `lsl_plugin` plugin. In the `liblsl`
