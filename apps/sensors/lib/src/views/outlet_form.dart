import 'package:flutter/material.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sensors/main.dart';
import 'package:sensors/src/models/outlet_config_dto.dart';
import 'package:sensors/src/widgets/field_label.dart';

class OutletFormScreen extends StatefulWidget {
  final OutletConfigDto? defaultConfig;
  const OutletFormScreen({super.key, this.defaultConfig});

  @override
  State<OutletFormScreen> createState() => _OutletFormScreenState();
}

class _OutletFormScreenState extends State<OutletFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers or state variables
  late final TextEditingController _nameController =
      TextEditingController(text: widget.defaultConfig?.name);
  late final TextEditingController _typeController =
      TextEditingController(text: widget.defaultConfig?.type);
  late final TextEditingController _channelCountController =
      TextEditingController(
          text: widget.defaultConfig?.channelCount.toString());
  late final TextEditingController _samplingRateController =
      TextEditingController(
          text: widget.defaultConfig?.nominalSRate.toString());
  late final TextEditingController _chunkSizeController =
      TextEditingController(text: widget.defaultConfig?.chunkSize.toString());
  late final TextEditingController _maxBufferedController =
      TextEditingController(text: widget.defaultConfig?.maxBuffered.toString());
  late final TextEditingController _offsetCalculationIntervalController =
      TextEditingController(
          text: widget.defaultConfig?.offsetCalculationInterval.toString());

  late bool? _useLslTimestamps = widget.defaultConfig?.useLslTimestamps;
  bool? _createMarkerStream = false;

  late ChannelFormat _channelFormat =
      widget.defaultConfig?.channelFormat ?? Int32ChannelFormat();
  final List<ChannelFormat> _channelFormats = [
    Int8ChannelFormat(),
    Int16ChannelFormat(),
    Int32ChannelFormat(),
    Int64ChannelFormat(),
    Float32ChannelFormat(),
    Double64ChannelFormat(),
    CftStringChannelFormat()
  ];

  late OffsetMode _mode = widget.defaultConfig?.mode ?? OffsetMode.none;
  final List<OffsetMode> _modes = [
    OffsetMode.none,
    OffsetMode.record,
    OffsetMode.applyFirstToSamples
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<OutletProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Outlet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              const FieldLabel(
                label: 'Name',
                tooltip: 'The name of the stream you are creating.',
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              // Type
              const FieldLabel(
                label: 'Type',
                tooltip:
                    'The type of data to be streamed, e.g. EEG, PPG, Audio etc.',
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  hintText: 'Enter type',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const FieldLabel(
                label: 'Channel format',
                tooltip: 'The format of the data to be streamed.',
              ),
              DropdownButtonFormField<String>(
                value: _channelFormat.toString(),
                items: _channelFormats
                    .map((type) => DropdownMenuItem(
                        value: type.toString(), child: Text(type.toString())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _channelFormat = _channelFormats
                        .firstWhere((format) => format.toString() == value));
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Pick format',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              // Channel count
              const FieldLabel(
                label: 'Channel count',
                tooltip: 'The number of channels of the stream.',
              ),
              TextFormField(
                controller: _channelCountController,
                decoration: const InputDecoration(
                  labelText: 'Enter channel count',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Nominal sampling rate
              const FieldLabel(
                label: 'Nominal sampling rate',
                tooltip: 'The nominal sampling rate of the stream.',
              ),
              TextFormField(
                controller: _samplingRateController,
                decoration: const InputDecoration(
                  labelText: 'Enter nominal sampling rate',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              // Separation
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Additional config
              // Chunk size
              const FieldLabel(
                label: 'Chunk size',
                tooltip:
                    'The desired chunk granularity (in samples) for transmission. If specified as 0, each push operation yields one chunk',
              ),
              TextFormField(
                controller: _chunkSizeController,
                decoration: const InputDecoration(
                  labelText: 'Enter chunk size',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Max buffered
              const FieldLabel(
                label: 'Max buffered',
                tooltip:
                    'Optionally the maximum amount of data to buffer (in seconds if there is a nominal sampling rate, otherwise x100 in samples). A good default is 360, which corresponds to 6 minutes of data. Note that, for high-bandwidth data you will almost certainly want to use a lower value here to avoid  running out of RAM.',
              ),
              TextFormField(
                controller: _maxBufferedController,
                decoration: const InputDecoration(
                  labelText: 'Enter max buffered',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Use LSL timestamps
              const FieldLabel(
                label: 'Use LSL timestamps',
                tooltip: 'Whether LSL should generate timestamps for you.',
              ),
              Checkbox(
                  value: _useLslTimestamps,
                  onChanged: (val) => setState(() => _useLslTimestamps = val)),
              // Offset mode
              const SizedBox(height: 12),
              const FieldLabel(
                label: 'Offset mode',
                tooltip:
                    'External sensors may have internal clocks that have drifted. Setting none, will keep the provided timestamps of sample as is. Setting record will record the offsets to be accessed along the data, and apply first to samples will simply apply the first recorded offset between the external device and this device and apply to each sample as they are pushed.',
              ),
              DropdownButtonFormField<String>(
                value: _mode.value,
                items: _modes
                    .map((mode) => DropdownMenuItem(
                        value: mode.value, child: Text(mode.value)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mode =
                        _modes.firstWhere((mode) => mode.value == value));
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Pick offset mode',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              // Offset calculation
              const FieldLabel(
                label: 'Offset calculation interval',
                tooltip:
                    'The interval in seconds in which the offset between the streaming device and the sensor is recorded.',
              ),
              TextFormField(
                controller: _offsetCalculationIntervalController,
                decoration: const InputDecoration(
                  labelText: 'Enter offset calculation interval',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              // Use LSL timestamps
              const SizedBox(height: 12),
              const FieldLabel(
                label: 'Create marker stream',
                tooltip:
                    'Whether an accompanying marker stream should be created',
              ),
              Checkbox(
                  value: _createMarkerStream,
                  onChanged: (val) =>
                      setState(() => _createMarkerStream = val)),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _isLoading = true;
                    });
                    appState.updateDeviceName(
                        widget.defaultConfig?.name, _nameController.text);
                    appState.addStream(OutletConfigDto(
                        name: _nameController.text,
                        type: _typeController.text,
                        streamType: widget.defaultConfig?.streamType ??
                            StreamType.gyroscope,
                        channelFormat: _channelFormat,
                        createMarkerStream: _createMarkerStream ?? false,
                        offsetCalculationInterval: double.parse(
                            _offsetCalculationIntervalController.text),
                        mode: _mode,
                        useLslTimestamps: _useLslTimestamps ?? true,
                        maxBuffered: int.parse(_maxBufferedController.text),
                        chunkSize: int.parse(_chunkSizeController.text),
                        sourceId: _nameController.text,
                        nominalSRate:
                            double.parse(_samplingRateController.text),
                        channelCount: int.parse(_channelCountController.text)));
                    // Go back
                    Navigator.pop(context);
                  }
                },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Outlet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
