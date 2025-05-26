import 'dart:async';
import 'dart:math';

/// A class that provides a sine wave stream.
class SineWaveStream {
  /// samples per second
  final double samplingRate;

  /// peak amplitude
  final double amplitude;

  /// period length in seconds
  final double wavelength;

  /// Index for validation, double to match the channel format
  double index = 0;

  StreamController<(double, double)>? _controller;
  Timer? _timer;

  SineWaveStream({
    required this.samplingRate,
    required this.amplitude,
    required this.wavelength,
  });

  Stream<(double, double)> get stream {
    _controller ??= StreamController<(double, double)>(
      onListen: _start,
      onCancel: _stop,
    );
    return _controller!.stream;
  }

  void _start() {
    final period = Duration(
        microseconds: (1e6 / samplingRate).round()); // convert Hz to µs
    double time = 0;
    final increment = 1 / samplingRate;
    final frequency = 1 / wavelength;

    _timer = Timer.periodic(period, (_) {
      final sample = amplitude * sin(2 * pi * frequency * time);
      _controller?.add((sample, index));
      index += 1;
      time += increment;
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
