import 'dart:ffi';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'outlet_test.mocks.dart';

class MockLsl implements LslInterface {
  final LslPluginBindings _bindings = MockLslPluginBindings();
  @override
  LslPluginBindings get bindings => _bindings;
}

@GenerateNiceMocks([MockSpec<LslPluginBindings>(), MockSpec<MulticastLock>()])
void main() {
  late Pointer<lsl_streaminfo_struct_> streamInfoPointer;
  late Pointer<lsl_outlet_struct_> outletPointer;

  setUpAll(() {
    // Use the mock native bindings and mock mutlicast lock
    MockLsl mockLsl = MockLsl();
    MockMulticastLock mockMulticastLock = MockMulticastLock();
    StreamInfo.setBindings(mockLsl);
    IntOutlet.setBindings(mockLsl);
    IntOutlet.setMulticastLock(mockMulticastLock);

    // Mockito does not know how to make dummy native values so we must provide them
    streamInfoPointer = malloc.allocate<lsl_streaminfo_struct_>(
        sizeOf<Pointer<lsl_streaminfo_struct_>>());
    outletPointer = malloc
        .allocate<lsl_outlet_struct_>(sizeOf<Pointer<lsl_outlet_struct_>>());
    provideDummy<Pointer<lsl_streaminfo_struct_>>(streamInfoPointer);
    provideDummy<Pointer<lsl_outlet_struct_>>(outletPointer);
  });

  tearDownAll(() {
    // Make sure to clean up memory after tests are run
    malloc.free(streamInfoPointer);
    malloc.free(outletPointer);
  });

  test(
      "Setting the channel format to a floating point format on an integer outlet should cause a runtime error",
      () {
    final outletBuilder = IntOutletBuilder();
    outletBuilder.name = "Test";
    outletBuilder.type = "EEG";
    outletBuilder.sourceId = "Testing Id";
    outletBuilder.channelFormat = ChannelFormat.float32;
    final result = outletBuilder.build();

    expect(result is Error, true);
  });

  test(
      "Setting the channel format to a 8 bit integer format on an integer outlet should be ok",
      () {
    final outletBuilder = IntOutletBuilder();
    outletBuilder.name = "Test";
    outletBuilder.type = "EEG";
    outletBuilder.sourceId = "Testing Id";
    outletBuilder.channelFormat = ChannelFormat.int8;
    final outlet = outletBuilder.build();

    switch (outlet) {
      case Ok(value: var outlet):
        var result = outlet.pushSample([1, 3, 4, 5]);
        expect(result is Ok, true);
      default:
        fail("Should not fail");
    }
  });
}
