import Flutter
import UIKit
import Muse

public class MuseSdkPlugin: NSObject, FlutterPlugin {
    var museManager: IXNMuseManager?
    var museListener: IXNMuseListener?
    var dataListener: IXNMuseDataListener?
    var connectionListener: IXNMuseConnectionListener?
    var logManager: IXNLogManager?
    var museList: [String] = []
    var museMap = [String: IXNMuse]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "muse_sdk", binaryMessenger: registrar.messenger())
        let instance = MuseSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
