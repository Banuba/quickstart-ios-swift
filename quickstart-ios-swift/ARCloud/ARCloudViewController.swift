import UIKit
import BanubaSdk
import BanubaEffectPlayer
import BanubaARCloudSDK

class ARCloudViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video, renderContentMode: .resizeAspectFill)
    private var effectArray: [AREffectModel]? = []

    //MARK: - ARCloud

    // Start loading all effect previews from AR Cloud
    private func loadAREffectPreviews() {
        DispatchQueue.main.async {
            ARCloudManager.fetchAREffects(completion: { [weak self] array  in
                guard let self = self else { return }
                self.effectArray = array
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            })
        }
    }

    // Start loading tapped effect by the effect name
    private func downloadAREffect(newEffectName: String, synchronous: Bool) {
        _ = sdkManager.loadEffect(newEffectName, synchronous: synchronous)
    }

    // Show alert if Client Cloud Id is empty in ARCloudManager/clientCloudId
    private func showCloudIdAlertIfNeeded() {
        guard ARCloudManager.clientCloudId != "" else {
            let alert = UIAlertController(
                title: "Invalid Client Cloud Id",
                message: "Please add Client Cloud Id to ARCloud/ARCloudManager.swift!",
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCollectionViewCell", for: indexPath) as! EffectCollectionViewCell
        let effect = self.effectArray?[indexPath.item]

        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: effect?.previewUrl ?? ""),
                  let imageData = try? Data(contentsOf: url)
            else { return }

            DispatchQueue.main.async {
                cell.titleLabel.text = effect?.title
                cell.previewImage.image = UIImage(data: imageData)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effect = self.effectArray?[indexPath.item]
        guard let effectName = effect?.title else { return }
        activityIndicator.startAnimating()

        ARCloudManager.loadTappedEffect(effectName: effectName) { [weak self] effectUrl in
            guard let self = self else { return }
            self.downloadAREffect(newEffectName: effectName, synchronous: true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.effectArray?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            CGSize(width: 180, height: 180)
    }

    deinit {
        sdkManager.destroyEffectPlayer()
    }

    @IBAction func closeARCloud(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Camera
extension ARCloudViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAREffectPreviews()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
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
}
