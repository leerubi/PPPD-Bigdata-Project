import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {




    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var keyTextLabel: UILabel!
    //    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            audioEngine.stop()
            recognitionTask?.cancel()
            isRecording = false
            startButton.backgroundColor = UIColor.gray
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.backgroundColor = UIColor.red
        }
    }
    
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }

    func recordAndRecognizeSpeech() {

        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }

func requestSpeechAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        OperationQueue.main.addOperation {
            switch authStatus {
            case .authorized:
                self.startButton.isEnabled = true
            case .denied:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "User denied access to speech recognition"
            case .restricted:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "Speech recognition restricted on this device"
            case .notDetermined:
                self.startButton.isEnabled = false
                self.detectedTextLabel.text = "Speech recognition not yet authorized"
            }
        }
    }
}
    

    
    func checkForColorsSaid(resultString: String) {
        switch resultString {
        case "그림":
            imageView.image = UIImage(named: "\(resultString).png")
            self.keyTextLabel.text = resultString

        case "피":
            imageView.image = UIImage(named: "\(resultString).png")
            self.keyTextLabel.text = "P-value"
            
        case "중요":
            imageView.image = UIImage(named: "\(resultString).png")
            self.keyTextLabel.text = resultString
            
//        case "red":
//            colorView.backgroundColor = UIColor.red
//        case "orange":
//            colorView.backgroundColor = UIColor.orange
//        case "yellow":
//            colorView.backgroundColor = UIColor.yellow
//        case "green":
//            colorView.backgroundColor = UIColor.green
//        case "blue":
//            colorView.backgroundColor = UIColor.blue
//        case "purple":
//            colorView.backgroundColor = UIColor.purple
//        case "black":
//            colorView.backgroundColor = UIColor.black
//        case "white":
//            colorView.backgroundColor = UIColor.white
//        case "gray":
//            colorView.backgroundColor = UIColor.gray
        default: break
        }
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
