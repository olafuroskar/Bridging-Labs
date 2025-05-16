import 'package:flutter/material.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scripted/main.dart';
import 'package:scripted/src/models/outlet_config_dto.dart';
import 'package:scripted/src/widgets/field_label.dart';

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

  late final TextEditingController _amplitudeController =
      TextEditingController(text: widget.defaultConfig?.amplitude.toString());
  late final TextEditingController _wavelengthController =
      TextEditingController(text: widget.defaultConfig?.wavelength.toString());

  late StreamType _streamType =
      widget.defaultConfig?.streamType ?? StreamType.random;
  final _streamTypes = [StreamType.random, StreamType.sine];

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
              Text(
                "Stream Information",
                style: TextStyle(fontSize: 20),
              ),
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
                  hintText: 'Enter channel count',
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
                  hintText: 'Enter nominal sampling rate',
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

              Text(
                "Outlet Information",
                style: TextStyle(fontSize: 20),
              ),
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
                  hintText: 'Enter chunk size',
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
                  hintText: 'Enter max buffered',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              // Separation
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                "Stream type",
                style: TextStyle(fontSize: 20),
              ),
              const FieldLabel(
                label: 'Stream type',
                tooltip: 'Whether to stream random data or sine wave data',
              ),
              DropdownButtonFormField<String>(
                value: _streamType.toString(),
                items: _streamTypes
                    .map((type) => DropdownMenuItem(
                        value: type.toString(), child: Text(type.toString())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _streamType = _streamTypes
                        .firstWhere((type) => type.toString() == value));
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Pick stream type',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const FieldLabel(
                label: 'Sine wave amplitude',
                tooltip: 'Amplitude of the sine wave or random range',
              ),
              TextFormField(
                controller: _amplitudeController,
                decoration: const InputDecoration(
                  hintText: 'Enter amplitude',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Wavelength
              const FieldLabel(
                label: 'Sine wave wavelength',
                tooltip: 'Wavelength of the sine wave',
              ),
              TextFormField(
                controller: _wavelengthController,
                enabled: _streamType == StreamType.sine,
                decoration: const InputDecoration(
                  hintText: 'Enter wavelength',
                  border: OutlineInputBorder(), // optional, for better visuals
                  isDense: true, // tighter vertical spacing
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _isLoading = true;
                    });
                    appState.addStream(OutletConfigDto(
                        name: _nameController.text,
                        type: _typeController.text,
                        streamType: _streamType,
                        channelFormat: _channelFormat,
                        amplitude: double.parse(_amplitudeController.text),
                        wavelength: double.parse(_wavelengthController.text),
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
