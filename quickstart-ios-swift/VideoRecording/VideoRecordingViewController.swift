import UIKit
import BNBSdkApi

class VideoRecordingViewController: UIViewController {

    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var recordButton: UIButton!
    
    private let player = Player()
    private let cameraDevice = CameraDevice(cameraMode: .FrontCameraSession, captureSessionPreset: .hd1280x720)
    private var videoOutput: Video!

    private var fileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("video.mp4")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoOutput = Video(cameraDevice: cameraDevice)
        player.use(input: Camera(cameraDevice: cameraDevice), outputs: [effectView, videoOutput])
        cameraDevice.start()

        effectView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = player.load(effect: "TrollGrandma", sync: true)
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushRecordButton(_ sender: UIButton) {
        if videoOutput.state == .stopped {
            videoOutput.record(url: self.fileURL, size: player.size) { state in
                switch state {
                case .recording, .paused:
                    self.recordButton.setImage(UIImage(named: "stop_video"), for: .normal)
                case .stopped, .processing:
                    self.recordButton.setImage(UIImage(named: "shutter_video"), for: .normal)
                @unknown default:
                    break
                }
            } onFinished: { success, error in
                let alert = UIAlertController(title: "Video Recording", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                if let error = error, !success {
                    // show video recording error
                    alert.message = error.localizedDescription
                } else {
                    // propose to save recorded video
                    alert.message = "Would you like to save recorded video in gallery?"
                    alert.addAction(UIAlertAction(title: "Save", style: .default) { action in
                        self.saveVideoToGallery(fileURL: self.fileURL.relativePath)
                    })
                }
                self.present(alert, animated: true, completion: nil)
            } onProgress: { duration in
                let time = round(duration)
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                let text = String(format: "%02d : %02d", minutes, seconds)
                print("Video recording in progress: \(text)")
            }
        } else {
            videoOutput.stop()
        }
    }
    
    private func saveVideoToGallery(fileURL: String) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL) {
            UISaveVideoAtPathToSavedPhotosAlbum(fileURL, nil, nil, nil)
        }
    }
}
