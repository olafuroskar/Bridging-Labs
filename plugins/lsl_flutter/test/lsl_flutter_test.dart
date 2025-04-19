import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/liblsl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:multicast_lock/multicast_lock.dart';
import 'package:test/test.dart';

import 'lsl_flutter_test.mocks.dart';

// Use the mock native bindings and mock mutlicast lock
final LslBindingsBindings _mockBindings = MockLslBindingsBindings();
final MockMulticastLock _mockMulticastLock = MockMulticastLock();

@GenerateNiceMocks([MockSpec<LslBindingsBindings>(), MockSpec<MulticastLock>()])
void main() {
  late Pointer<lsl_streaminfo_struct_> streamInfoPointer;
  late Pointer<lsl_outlet_struct_> outletPointer;

  setUpAll(() {
    Lsl.setBindings(_mockBindings);
    Lsl.setMulticastLock(_mockMulticastLock);

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

      outletManager.pushSample([1.0, 3.2, 4.3, 5.3]);

      outletManager.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
    });

    test(
        "Setting the channel format to a 64 bit double should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Test", "EEG", Double64ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      outletManager.pushSample([1.0, 3.2, 4.3, 5.3]);

      outletManager.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
    });
  });

  group("Integer outlets", () {
    test(
        "Setting the channel format to a 64 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int64ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      outletManager.pushSample([1, 3, 4, 5]);

      outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
    });

    test(
        "Setting the channel format to a 32 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int32ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      outletManager.pushSample([1, 3, 4, 5]);

      outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
    });

    test(
        "Setting the channel format to a 16 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int16ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      outletManager.pushSample([1, 3, 4, 5]);

      outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
    });

    test(
        "Setting the channel format to a 8 bit integer should be ok, and pushing a valid sample should work",
        () {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Test", "EEG", Int8ChannelFormat());
      final outletManager = OutletManager(streamInfo);

      outletManager.pushSample([1, 3, 4, 5]);

      outletManager.pushChunk([
        [1, 3, 4, 5],
        [1, 3, 4, 5]
      ]);
    });
  });
}
