part of 'inlets.dart';

/// Class that encapsulates the native inlet reference used by the inlet adapters
class InletContainer {
  Inlet inlet;
  final lsl_inlet _nativeInlet;

  InletContainer._(this.inlet, this._nativeInlet);
}
