part of 'outlets.dart';

/// Class that encapsulates the native inlet reference used by the inlet adapters
class OutletContainer {
  Outlet outlet;
  final lsl_outlet _nativeOutlet;

  OutletContainer._(this.outlet, this._nativeOutlet);
}
