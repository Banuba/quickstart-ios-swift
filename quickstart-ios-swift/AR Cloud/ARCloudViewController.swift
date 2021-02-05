import UIKit
import BanubaSdk
import BanubaEffectPlayer

class ARCloudViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet var dataProvider: EffectDataProvider!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    
    var effectUrl = "UnluckyWitch" {
        willSet(newEffect) {
            self.loadEffect(effectUrl: newEffect)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadEffectThumbs()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        sdkManager.input.startCamera()
        loadEffect(effectUrl: effectUrl)
        sdkManager.startEffectPlayer()
    }

    private func loadEffect(effectUrl: String) {
        _ = sdkManager.loadEffect(effectUrl, synchronous: true)
    }

    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        sdkManager.stopEffectPlayer()
        sdkManager.removeRenderTarget()
        coordinator.animateAlongsideTransition(in: effectView, animation: { (UIViewControllerTransitionCoordinatorContext) in
            self.sdkManager.autoRotationEnabled = true
            self.setUpRenderSize()
        }, completion: nil)
    }
    
    private func loadEffectThumbs() {
        DispatchQueue.main.async {
            ARCloudManager.fetchAREffects(complition: { array  in
                self.dataProvider.dataManager.effectArray = array
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    private func setUpRenderTarget() {
        guard let effectView = self.effectView.layer as? CAEAGLLayer else { return }
        sdkManager.setRenderTarget(layer: effectView, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
    }
    
    private func setUpRenderSize() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            config.orientation = .deg90
            config.renderSize = CGSize(width: 720, height: 1280)
            sdkManager.autoRotationEnabled = false
            setUpRenderTarget()
        case .portraitUpsideDown:
            config.orientation = .deg270
            config.renderSize = CGSize(width: 720, height: 1280)
            setUpRenderTarget()
        case .landscapeLeft:
            config.orientation = .deg180
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        case .landscapeRight:
            config.orientation = .deg0
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        default:
            setUpRenderTarget()
        }
    }
    
    @IBAction func closeARCloud(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
