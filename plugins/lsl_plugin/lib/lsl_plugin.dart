/// A library for interacting with the Lab Streaming Layer
library;

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/inlets/processing_options.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
// TODO: Ekki gott
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

// Managers
export 'src/managers/managers.dart';

// Utils
part 'src/adapters/streams/resolved_stream_handle.dart';

// Types
part 'src/types.dart';

// Domain
part 'package:lsl_plugin/src/domain/outlet.dart';
part 'package:lsl_plugin/src/domain/inlet.dart';
part 'package:lsl_plugin/src/domain/stream_info.dart';

// Factories
part 'src/stream_info_factory.dart';

// Channel formats
part 'src/channel_formats/int_channel_format.dart';
part 'src/channel_formats/double_channel_format.dart';
part 'src/channel_formats/string_channel_format.dart';

// Isolate workers
part 'src/workers/outlet_worker.dart';
part 'src/workers/inlet_worker.dart';

// Helpers
part 'src/utils/helpers.dart';
part 'src/utils/timestamp.dart';
