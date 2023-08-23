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
        if videoOutput.state == VideoRecordingState.stopped {
            videoOutput.record(url: self.fileURL, size: player.size) { state in
            } onFinished: { success, error in
                guard success else { return }
                self.saveVideoToGallery(fileURL: self.fileURL.relativePath)
            } onProgress: { duration in
            }
            self.recordButton.setImage(UIImage(named: "stop_video"), for: .normal)
        } else {
            videoOutput.stop()
            self.recordButton.setImage(UIImage(named: "shutter_video"), for: .normal)
        }
    }
    
    private func saveVideoToGallery(fileURL: String) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL) {
            UISaveVideoAtPathToSavedPhotosAlbum(fileURL, nil, nil, nil)
        }
    }
}
