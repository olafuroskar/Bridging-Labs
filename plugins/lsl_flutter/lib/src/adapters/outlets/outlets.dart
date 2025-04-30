/// Library for outlet adapters
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/liblsl.dart';
import 'package:lsl_flutter/src/utils/stream_info.dart' as stream_utils;

part 'outlet_adapter.dart';
part 'outlet_adapter_factory.dart';
part 'outlet_container.dart';
part 'utils.dart';

part 'implementations/int_outlet_adapter.dart';
part 'implementations/short_outlet_adapter.dart';
part 'implementations/long_outlet_adapter.dart';
part 'implementations/double_outlet_adapter.dart';
part 'implementations/float_outlet_adapter.dart';
part 'implementations/string_outlet_adapter.dart';
