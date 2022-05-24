import UIKit
import BNBSdkApi

class ProcessImageController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    private let imagePicker = UIImagePickerController()
    private var image : UIImage?
    
    private var hairGreenValue: Float = 0.0
    private var eyesGreenValue: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if (image != nil) {
            self.sdkManager.captureEditedImage(completion: {
                (processedImage) in self.image = processedImage})
            self.sdkManager.stopEditingImage()
        }
        sdkManager.stopEffectPlayer()
        sdkManager.removeRenderTarget()
        coordinator.animateAlongsideTransition(in: effectView, animation: { (UIViewControllerTransitionCoordinatorContext) in
            self.sdkManager.autoRotationEnabled = true
            self.setUpRenderSize()
        }, completion: nil)
    }
    
    private func setUpRenderTarget() {
        sdkManager.setRenderTarget(view: effectView, playerConfiguration: nil)
        
        _ = sdkManager.loadEffect("Makeup", synchronous: true)
        sdkManager.currentEffect()?.evalJs("Eyes.color('1.0 \(eyesGreenValue) 0.0 0.5')", resultCallback: nil)
        sdkManager.currentEffect()?.evalJs("Hair.color('1.0 \(hairGreenValue) 0.0 0.5')", resultCallback: nil)
        
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
        default: break
        }
        
        setUpRenderTarget()
        guard let image = self.image else {return}
        self.sdkManager.startEditingImage(image)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func hairValueChanged(_ sender: UISlider) {
        hairGreenValue = sender.value / 10
        sdkManager.currentEffect()?.evalJs("Hair.color('1.0 \(hairGreenValue) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func eyesValueChanged(_ sender: UISlider) {
        eyesGreenValue = sender.value / 10
        sdkManager.currentEffect()?.evalJs("Eyes.color('1.0 \(eyesGreenValue) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProcessImageController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.effectView.contentMode = .scaleAspectFit
            image = pickedImage
            self.sdkManager.startEditingImage(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
