import UIKit
import BNBSdkApi
import BNBSdkCore

class CameraViewController: UIViewController {
    // Output surface for the `Player`
    @IBOutlet weak var effectView: EffectPlayerView!
    
    // Input stream for the `Player`
    private let cameraDevice = CameraDevice(
        cameraMode: .FrontCameraSession,
        captureSessionPreset: .hd1280x720
    )
    
    // `Player` process frames from the input and render them into the outputs
    private let player = Player()
    
    // Current effect
    private var effect: BNBEffect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect `CameraDevice` and `EffectPlayerView` to `Player`
        player.use(input: Camera(cameraDevice: cameraDevice))
        player.use(outputs: [effectView])
        
        // Load effect from `effects` folder
        effect = player.load(effect: "TrollGrandma")
        
        // Start feeding frames from camera
        cameraDevice.start()
    }

    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
