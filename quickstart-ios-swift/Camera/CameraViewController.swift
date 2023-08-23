import UIKit
import BNBSdkApi

class CameraViewController: UIViewController {
    @IBOutlet weak var effectView: EffectPlayerView!
    private let player = Player()

    override func viewDidLoad() {
        super.viewDidLoad()
        let cameraDevice = CameraDevice(
            cameraMode: .FrontCameraSession,
            captureSessionPreset: .hd1280x720
        )
        cameraDevice.start()
        player.use(input: Camera(cameraDevice: cameraDevice), outputs: [effectView])
        _ = player.load(effect: "TrollGrandma")
    }

    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
