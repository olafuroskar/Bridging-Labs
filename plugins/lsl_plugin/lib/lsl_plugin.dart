/// A library for interacting with the Lab Streaming Layer
library;

import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/repositories/outlets/outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/outlet_repository_factory.dart';
import 'package:lsl_plugin/src/services/utils.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

// Result (Error/Ok) utils
part 'src/utils/result.dart';

// Domain
part 'package:lsl_plugin/src/domain/outlet.dart';
part 'package:lsl_plugin/src/domain/stream_info.dart';

// Services
part 'src/services/outlet_service.dart';
part 'src/services/stream_info_service.dart';

// Channel formats
part 'src/channel_formats/int_channel_format.dart';
part 'src/channel_formats/double_channel_format.dart';
part 'src/channel_formats/string_channel_format.dart';
