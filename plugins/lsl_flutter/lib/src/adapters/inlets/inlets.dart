library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/adapters/inlets/processing_options.dart';
import 'package:lsl_flutter/src/adapters/inlets/utils.dart' as utils;
import 'package:lsl_flutter/src/adapters/streams/resolved_stream.dart';
import 'package:lsl_flutter/src/adapters/utils.dart';
import 'package:lsl_flutter/src/liblsl.dart';
import 'package:lsl_flutter/src/utils/error_code.dart';

part 'implementations/int_inlet_adapter.dart';
part 'implementations/short_inlet_adapter.dart';
part 'implementations/long_inlet_adapter.dart';
part 'implementations/double_inlet_adapter.dart';
part 'implementations/float_inlet_adapter.dart';
part 'implementations/string_inlet_adapter.dart';
part 'inlet_adapter_factory.dart';

part 'inlet_adapter.dart';
part 'inlet_container.dart';
