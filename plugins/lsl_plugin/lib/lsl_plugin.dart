/// A library for interacting with the Lab Streaming Layer
library;

import 'dart:ffi';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/double_channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/int_channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/string_channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/outlets/outlet.dart';
import 'package:lsl_plugin/src/outlets/outlet_builder.dart';
import 'package:lsl_plugin/src/samples/double_samples/double_sample_strategy_factory.dart';
import 'package:lsl_plugin/src/samples/int_samples/int_sample_strategy_factory.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/string_samples/string_sample_strategy_factory.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

part 'src/outlets/int/int_outlet.dart';
part 'src/outlets/int/int_outlet_builder.dart';
part 'src/outlets/double/double_outlet.dart';
part 'src/outlets/double/double_outlet_builder.dart';
part 'src/outlets/string/string_outlet.dart';
part 'src/outlets/string/string_outlet_builder.dart';
part 'src/stream_info.dart';
