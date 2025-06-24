/// A library for interacting with the Lab Streaming Layer
library;

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/liblsl.dart';

// Managers
export 'src/managers/managers.dart';

// Utils
part 'src/adapters/streams/resolved_stream_handle.dart';

// Types
part 'src/types.dart';

// Domain
part 'package:lsl_flutter/src/domain/outlet.dart';
part 'package:lsl_flutter/src/domain/inlet.dart';
part 'package:lsl_flutter/src/domain/stream_info.dart';

// Factories
part 'src/stream_info_factory.dart';

// Channel formats
part 'src/channel_formats/channel_format.dart';
part 'src/channel_formats/int_channel_format.dart';
part 'src/channel_formats/double_channel_format.dart';
part 'src/channel_formats/string_channel_format.dart';

// Isolate workers
part 'src/workers/outlet_worker.dart';
part 'src/workers/inlet_worker.dart';

// Helpers
part 'src/utils/helpers.dart';
part 'src/utils/timestamp.dart';
part "src/processing_options.dart";
