import UIKit
import BanubaSdk

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfinguration(renderMode: .video)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        effectView?.effectPlayer = sdkManager.effectPlayer
        guard let effectView = self.effectView.layer as? CAEAGLLayer else { return }
        sdkManager.setRenderTarget(layer: effectView, playerConfiguration: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       changeRenderSizeAndOrientation()
       sdkManager.input.startCamera()
       sdkManager.loadEffect("UnluckyWitch", synchronous: true)
       sdkManager.startEffectPlayer()
     }
    
    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
       changeRenderSizeAndOrientation()
    }
    
    private func setUpNewRenderTarget() {
       sdkManager.stopEffectPlayer()
       sdkManager.removeRenderTarget()
       guard let effectView = self.effectView.layer as? CAEAGLLayer else { return }
       sdkManager.setRenderTarget(layer: effectView, playerConfiguration: nil)
       sdkManager.startEffectPlayer()
    }
    
    private func changeRenderSizeAndOrientation() {
       switch UIDevice.current.orientation {
       case .portrait:
           config.orientation = .deg0
           config.renderSize = CGSize(width: 720, height: 1280)
           setUpNewRenderTarget()
       case .portraitUpsideDown:
           config.orientation = .deg0
           config.renderSize = CGSize(width: 720, height: 1280)
           setUpNewRenderTarget()
       case .landscapeLeft:
           config.orientation = .deg270
           config.renderSize = CGSize(width: 1280, height: 720)
           setUpNewRenderTarget()
       case .landscapeRight:
           config.orientation = .deg90
           config.renderSize = CGSize(width: 1280, height: 720)
           setUpNewRenderTarget()
       default:
           break
        }
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
