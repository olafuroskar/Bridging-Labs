import 'dart:ffi';

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

@GenerateNiceMocks([MockSpec<LslPluginBindings>()])
void main() {
  late Pointer<lsl_streaminfo_struct_> streamInfoPointer;
  late Pointer<lsl_outlet_struct_> outletPointer;

  setUpAll(() {
    // Use the mock native bindings
    MockLsl mockLsl = MockLsl();
    StreamInfo.setBindings(mockLsl);
    Outlet.setBindings(mockLsl);

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
      "Outlet with 32 bit floating point channel format can push explicitly integer samples",
      () {
    StreamInfo streamInfo = StreamInfo("Test Stream", "EEG");
    Outlet outlet = Outlet(streamInfo);

    List<int> sample = [1, 0, 2, 3];

    var result = outlet.pushSample(sample);

    expect(result is Error, true);
  });

  test(
      "Outlet with 32 bit floating point channel format can push explicitly double samples",
      () {
    StreamInfo streamInfo = StreamInfo("Test Stream", "EEG");
    Outlet outlet = Outlet(streamInfo);

    List<double> sample = [1.0, 0, 2, 3.2];

    var result = outlet.pushSample(sample);

    expect(result is Ok, true);
  });
}
