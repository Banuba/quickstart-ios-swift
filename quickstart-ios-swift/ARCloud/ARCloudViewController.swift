import UIKit
import BanubaSdk
import BanubaEffectPlayer

class ARCloudViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var dataProvider: EffectDataProvider!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video, renderContentMode: .resizeAspectFill)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAREffectPreviewIcon()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
        addNotificationCenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        sdkManager.input.startCamera()
        sdkManager.startEffectPlayer()
        showCloudIdAlertIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        sdkManager.stopEffectPlayer()
        sdkManager.removeRenderTarget()
        coordinator.animateAlongsideTransition(in: effectView, animation: { (UIViewControllerTransitionCoordinatorContext) in
            self.sdkManager.autoRotationEnabled = true
            self.setUpRenderSize()
        }, completion: nil)
    }

    deinit {
        sdkManager.destroyEffectPlayer()
        removeNotificationCenter()
    }

    private func downloadAREffect(newEffectName: String, synchronous: Bool) {
        _ = sdkManager.loadEffect(newEffectName, synchronous: synchronous)
    }

    private func showCloudIdAlertIfNeeded() {
        guard clientCloudId != "" else {
            let alert = UIAlertController(
                title: "Invalid Client Cloud Id",
                message: "Please add Client Cloud Id in BanubaClientToken.swift!",
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    private func loadAREffectPreviewIcon() {
        DispatchQueue.main.async {
            ARCloudManager.fetchAREffects(completion: { [weak self] array  in
                guard let self = self else { return }
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
        case .portraitUpsideDown:
            config.orientation = .deg270
            config.renderSize = CGSize(width: 720, height: 1280)
        case .landscapeLeft:
            config.orientation = .deg180
            config.renderSize = CGSize(width: 1280, height: 720)
        case .landscapeRight:
            config.orientation = .deg0
            config.renderSize = CGSize(width: 1280, height: 720)
        default:
            break
        }
        setUpRenderTarget()
    }
    
    @IBAction func closeARCloud(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ARCloudViewController {
    private func addNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateEffect),
            name: Notification.Name.newEffectDidLoad,
            object: nil
        )
    }

    private func removeNotificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.newEffectDidLoad, object: nil)
    }

    @objc private func updateEffect( _ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["name"] as? String {
                downloadAREffect(newEffectName: id, synchronous: true)
            }
        }
    }
}

extension Notification.Name {
    static let newEffectDidLoad = NSNotification.Name("newEffectDidLoad")
}
