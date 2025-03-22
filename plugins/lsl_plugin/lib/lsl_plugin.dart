/// A library for interacting with the Lab Streaming Layer
library;

import 'package:lsl_plugin/src/adapters/streams/implementations/async_stream_adapter.dart';
import 'package:lsl_plugin/src/adapters/streams/stream_adapter.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter_factory.dart';
import 'package:lsl_plugin/src/utils/adapters.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

// Utils
part 'src/utils/result.dart';
part 'src/adapters/streams/resolved_stream_handle.dart';

// Domain
part 'package:lsl_plugin/src/domain/outlet.dart';
part 'package:lsl_plugin/src/domain/stream_info.dart';

// Managers
part 'src/managers/outlet_manager.dart';
part 'src/managers/stream_manager.dart';

// Factories
part 'src/stream_info_factory.dart';

// Channel formats
part 'src/channel_formats/int_channel_format.dart';
part 'src/channel_formats/double_channel_format.dart';
part 'src/channel_formats/string_channel_format.dart';
