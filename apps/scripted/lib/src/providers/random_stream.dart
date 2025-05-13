import 'dart:async';
import 'dart:math';

/// A class that provides a sine wave stream.
class RandomStream {
  final double samplingRate; // samples per second
  final double amplitude; // peak amplitude

  StreamController<double>? _controller;
  final _random = Random();
  Timer? _timer;

  RandomStream({
    required this.samplingRate,
    required this.amplitude,
  });

  Stream<double> get stream {
    _controller ??= StreamController<double>(
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
      _controller?.add(sample);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
