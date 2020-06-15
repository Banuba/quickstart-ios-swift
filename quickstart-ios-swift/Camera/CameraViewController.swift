import UIKit
import BanubaSdk

class CameraViewController: UIViewController {
    
    private var sdkManager = BanubaSdkManager()
    @IBOutlet weak var effectView: EffectPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: EffectPlayerConfinguration(renderMode: .video))
        effectView?.effectPlayer = sdkManager.effectPlayer
        sdkManager.setRenderTarget(layer: effectView?.layer as! CAEAGLLayer, playerConfiguration: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sdkManager.input.startCamera()
        sdkManager.loadEffect("UnluckyWitch")
        sdkManager.startEffectPlayer()
    }
    
    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
