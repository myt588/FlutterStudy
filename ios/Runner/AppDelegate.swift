import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "flutterapp.tutorialspoint.com/browser",
                                                  binaryMessenger: controller.binaryMessenger)
        
        batteryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            guard call.method == "openBrowser" else {
                result(FlutterMethodNotImplemented)
                return
            }
            guard let arguments = call.arguments as? [String: Any],
                  let url = arguments ["url"] as? String else {
                return
            }
            self?.openBrowser(url)
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func openBrowser(_ urlString: String?) {
        let url = URL(string: urlString ?? "")
        let application = UIApplication.shared
        if let url = url {
            application.openURL(url)
        }
    }
    
}
