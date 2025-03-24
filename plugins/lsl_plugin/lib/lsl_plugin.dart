/// A library for interacting with the Lab Streaming Layer
library;

import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

// Managers
export 'src/managers/managers.dart';

// Utils
part 'src/utils/result.dart';
part 'src/adapters/streams/resolved_stream_handle.dart';

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
