import 'dart:ffi';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/double_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/float_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/int_outlet_repository.dart';
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

    DoubleOutletRepository.setBindings(mockLsl);
    DoubleOutletRepository.setMulticastLock(mockMulticastLock);

    FloatOutletRepository.setBindings(mockLsl);
    FloatOutletRepository.setMulticastLock(mockMulticastLock);

    IntOutletRepository.setBindings(mockLsl);
    IntOutletRepository.setMulticastLock(mockMulticastLock);

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
      final streamInfoService = StreamInfoService();
      final streamInfo = streamInfoService.createDoubleStreamInfo(
          "Test", "EEG", Float32ChannelFormat());
      final outletService = OutletService(streamInfo);

      final creation = outletService.create();
      expect(creation is Ok, true);

      var result = outletService.pushSample([1.0, 3.2, 4.3, 5.3]);
      expect(result is Ok, true);

      result = outletService.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
      expect(result is Ok, true);
    });

    test(
        "Setting the channel format to a 64 bit double should be ok, and pushing a valid sample should work",
        () {
      final streamInfoService = StreamInfoService();
      final streamInfo = streamInfoService.createDoubleStreamInfo(
          "Test", "EEG", Double64ChannelFormat());
      final outletService = OutletService(streamInfo);

      final creation = outletService.create();
      expect(creation is Ok, true);

      var result = outletService.pushSample([1.0, 3.2, 4.3, 5.3]);
      expect(result is Ok, true);

      result = outletService.pushChunk([
        [1.0, 3.2, 4.3, 5.3],
        [1.0, 3.2, 4.3, 5.3]
      ]);
      expect(result is Ok, true);
    });
  });

  // group("Integer outlets", () {
  //   final streamInfo = StreamInfoRename("TestInt", "EEG", Int32ChannelFormat());
  //
  //   final outlet = Outlet(streamInfo);
  //
  //   final outletRepo = IntOutletRepository();
  //   outletRepo.create(outlet);
  // });
}
