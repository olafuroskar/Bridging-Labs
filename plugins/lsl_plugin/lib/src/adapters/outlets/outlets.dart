library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/unit.dart';
import 'package:lsl_plugin/src/adapters/outlets/utils.dart' as utils;

part 'outlet_adapter.dart';
part 'outlet_adapter_factory.dart';
part 'outlet_container.dart';

part 'implementations/int_outlet_adapter.dart';
part 'implementations/short_outlet_adapter.dart';
part 'implementations/long_outlet_adapter.dart';
part 'implementations/double_outlet_adapter.dart';
part 'implementations/float_outlet_adapter.dart';
part 'implementations/string_outlet_adapter.dart';
