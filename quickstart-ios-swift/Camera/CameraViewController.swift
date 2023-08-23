import UIKit
import BNBSdkApi

class CameraViewController: UIViewController {
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var effectViewAspect: NSLayoutConstraint!
    
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
        
        resize(size: player.size)
        player.onResize { [weak self] size in
            self?.resize(size: size)
        }
    }

    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func resize(size: CGSize) {
        effectViewAspect.constant = size.width / size.height
    }
}
