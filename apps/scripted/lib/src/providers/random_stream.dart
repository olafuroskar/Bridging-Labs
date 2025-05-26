import 'dart:async';
import 'dart:math';

/// A class that provides a sine wave stream.
class RandomStream {
  /// samples per second
  final double samplingRate;

  /// peak amplitude
  final double amplitude;

  /// Index for validation, double to match the channel format
  double index = 0;

  StreamController<(double, double)>? _controller;
  final _random = Random();
  Timer? _timer;

  RandomStream({
    required this.samplingRate,
    required this.amplitude,
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

    _timer = Timer.periodic(period, (_) {
      // Uniform distribution in [-amplitude, amplitude]
      final sample = (_random.nextDouble() * 2 - 1) * amplitude;
      _controller?.add((sample, index));
      index += 1;
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
