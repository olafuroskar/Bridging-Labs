/// A library for interacting with the Lab Streaming Layer
library;

import 'dart:ffi';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/double_channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/int_channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/string_channel_format.dart';
import 'package:lsl_plugin/src/domain/outlet.dart';
import 'package:lsl_plugin/src/domain/stream_info.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/repositories/outlet_repository_factory.dart';
import 'package:lsl_plugin/src/repositories/utils.dart';
import 'package:lsl_plugin/src/services/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';
import 'package:lsl_plugin/src/utils/errors.dart';

/// Repositories
part 'src/repositories/outlet_repository.dart';
part 'src/repositories/int_outlet_repository.dart';
part 'src/repositories/short_outlet_repository.dart';
part 'src/repositories/long_outlet_repository.dart';
part 'src/repositories/float_outlet_repository.dart';
part 'src/repositories/double_outlet_repository.dart';
part 'src/repositories/string_outlet_repository.dart';

/// Services
part 'src/services/outlet_service.dart';
