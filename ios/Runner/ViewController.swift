import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resultView: UITextView!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://ichef.bbci.co.uk/news/1024/cpsprodpb/83D7/production/_111515733_gettyimages-1208779325.jpg")
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            imageView.image = image
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
            resultView.text = text
            
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
    }
}
