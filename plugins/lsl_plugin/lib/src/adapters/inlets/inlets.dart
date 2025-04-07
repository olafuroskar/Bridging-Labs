library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/inlets/utils.dart' as utils;
import 'package:lsl_plugin/src/adapters/streams/resolved_stream.dart';
import 'package:lsl_plugin/src/adapters/utils.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

part 'implementations/int_inlet_adapter.dart';
part 'implementations/short_inlet_adapter.dart';
part 'implementations/long_inlet_adapter.dart';
part 'implementations/double_inlet_adapter.dart';
part 'implementations/float_inlet_adapter.dart';
part 'implementations/string_inlet_adapter.dart';
part 'inlet_adapter_factory.dart';

part 'inlet_adapter.dart';
part 'inlet_container.dart';
