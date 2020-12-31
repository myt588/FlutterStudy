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
        
        let imageChannel = FlutterMethodChannel(name: "flutterapp.tutorialspoint.com/analyzeImage",
                                                  binaryMessenger: controller.binaryMessenger)
        
        imageChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            guard call.method == "analyzeImage" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.analyzeImage(call: call, result: result)
        })
        
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
    
    private lazy var module: TorchModule = {
        if let filePath = Bundle.main.path(forResource: "model", ofType: "pt"),
            let module = TorchModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Can't find the model file!")
        }
    }()

    private lazy var labels: [String] = {
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt"),
            let labels = try? String(contentsOfFile: filePath) {
            return labels.components(separatedBy: .newlines)
        } else {
            fatalError("Can't find the text file!")
        }
    }()

    func analyzeImage(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let urlString = arguments ["url"] as? String else {
            return
        }
        
        let url = URL(string: urlString)
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            let resizedImage = image!.resized(to: CGSize(width: 224, height: 224))
            guard var pixelBuffer = resizedImage.normalized() else {
                return
            }
            guard let outputs = module.predict(image: UnsafeMutableRawPointer(&pixelBuffer)) else {
                return
            }
            let zippedResults = zip(labels.indices, outputs)
            let sortedResults = zippedResults.sorted { $0.1.floatValue > $1.1.floatValue }.prefix(3)
            var text = ""
            for result in sortedResults {
                text += "\u{2022} \(labels[result.0]) \n\n"
            }
            result(text)
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
    }
    
}
