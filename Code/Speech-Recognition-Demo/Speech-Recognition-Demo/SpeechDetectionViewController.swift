import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var keyTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
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
        case "빨간색":
            colorView.backgroundColor = UIColor.red
            self.keyTextLabel.text = resultString
        case "주황색":
            colorView.backgroundColor = UIColor.orange
            self.keyTextLabel.text = resultString
        case "노란색":
            colorView.backgroundColor = UIColor.yellow
            self.keyTextLabel.text = resultString
        case "초록색":
            colorView.backgroundColor = UIColor.green
            self.keyTextLabel.text = resultString
        case "파란색":
            colorView.backgroundColor = UIColor.blue
            self.keyTextLabel.text = resultString
        case "보라색":
            colorView.backgroundColor = UIColor.purple
            self.keyTextLabel.text = resultString
        case "검정색":
            colorView.backgroundColor = UIColor.black
            self.keyTextLabel.text = resultString
        case "하얀색":
            colorView.backgroundColor = UIColor.white
            self.keyTextLabel.text = resultString
        case "회색":
            colorView.backgroundColor = UIColor.gray
            self.keyTextLabel.text = resultString
        default: break
        }
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
