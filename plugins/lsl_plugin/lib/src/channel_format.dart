// part of '../lsl_plugin.dart';
//
// enum channelformat {
//   float32(lsl_channel_format_t.cft_float32),
//   double64(lsl_channel_format_t.cft_double64),
//   int8(lsl_channel_format_t.cft_int8),
//   int16(lsl_channel_format_t.cft_int16),
//   int32(lsl_channel_format_t.cft_int32),
//   int64(lsl_channel_format_t.cft_int64),
//   string(lsl_channel_format_t.cft_string),
//   undefined(lsl_channel_format_t.cft_undefined);
//
//   final lsl_channel_format_t value;
//   const channelformat(this.value);
//
//   static channelformat fromvalue(lsl_channel_format_t value) => switch (value) {
//         lsl_channel_format_t.cft_float32 => float32,
//         lsl_channel_format_t.cft_double64 => double64,
//         lsl_channel_format_t.cft_int8 => int8,
//         lsl_channel_format_t.cft_int16 => int16,
//         lsl_channel_format_t.cft_int32 => int32,
//         lsl_channel_format_t.cft_int64 => int64,
//         lsl_channel_format_t.cft_string => string,
//         lsl_channel_format_t.cft_undefined => undefined,
//         _ => throw argumenterror(),
//       };
// }
