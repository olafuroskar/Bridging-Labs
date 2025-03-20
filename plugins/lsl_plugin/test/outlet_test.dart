import 'dart:ffi';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/long_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/short_outlet_adapter.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/double_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/float_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/int_outlet_adapter.dart';
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

    DoubleOutletAdapter.setBindings(mockLsl);
    DoubleOutletAdapter.setMulticastLock(mockMulticastLock);

    FloatOutletAdapter.setBindings(mockLsl);
    FloatOutletAdapter.setMulticastLock(mockMulticastLock);

    IntOutletAdapter.setBindings(mockLsl);
    IntOutletAdapter.setMulticastLock(mockMulticastLock);

    ShortOutletAdapter.setBindings(mockLsl);
    ShortOutletAdapter.setMulticastLock(mockMulticastLock);

    LongOutletAdapter.setBindings(mockLsl);
    LongOutletAdapter.setMulticastLock(mockMulticastLock);

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

  group("Double outlets", () {
    test(
        "Setting the channel format to a 32 bit float should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Test", "EEG", Float32ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1.0, 3.2, 4.3, 5.3]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
      expect(result is Ok, true);
    });

    test(
        "Setting the channel format to a 64 bit double should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Test", "EEG", Double64ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1.0, 3.2, 4.3, 5.3]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
      expect(result is Ok, true);
    });
  });

  group("Integer outlets", () {
    test(
        "Setting the channel format to a 64 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int64ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1, 3, 4, 5]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
      expect(result is Ok, true);
    });

    test(
        "Setting the channel format to a 32 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int32ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1, 3, 4, 5]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
      expect(result is Ok, true);
    });

    test(
        "Setting the channel format to a 16 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int16ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1, 3, 4, 5]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
      expect(result is Ok, true);
    });

    test(
        "Setting the channel format to a 8 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int8ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      final creation = outletManager.create();
      expect(creation is Ok, true);

      var result = outletManager.pushSample([1, 3, 4, 5]);
      expect(result is Ok, true);

      result = outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
      expect(result is Ok, true);
    });
  });
}
