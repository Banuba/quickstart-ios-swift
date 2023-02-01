import UIKit
import Foundation
import BNBSdkApi

class PhotoProcessingController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration()
    private let imagePicker = UIImagePickerController()
    private var image : UIImage?
    
    private var hairGreenValue: Float = 0.0
    private var eyesGreenValue: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
        
        if ( loadMakeup() ) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        } else {
            processAbsentMakeup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            _ = self.loadMakeup()
            
            guard let image = self.image else {return}
            self.sdkManager.startEditingImage(image)
        }, completion: nil)
    }
    
    private func setUpRenderTarget() {
        sdkManager.setRenderTarget(view: effectView, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
    }

    private func loadMakeup() -> Bool {
        let effect = sdkManager.loadEffect("Makeup", synchronous: true)
        if let m_effect = effect {
            if ( m_effect.url().hasSuffix("Makeup") ) {
                sdkManager.currentEffect()?.evalJs("Hair.color('1.0 \(hairGreenValue) 0.0 0.5')", resultCallback: nil)
                sdkManager.currentEffect()?.evalJs("Eyes.color('1.0 \(eyesGreenValue) 0.0 0.5')", resultCallback: nil)
                return true
            }
        }
        return false
    }

    private func processAbsentMakeup() {
        let alert = UIAlertController(
            title: "Can't load the Makeup effect",
            message: "This view requires the Makeup effect in the 'effects' folder. You can find information about how to get the effect in README.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction( title: "OK", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
        selectImageButton.isHidden = true
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

extension PhotoProcessingController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.effectView.contentMode = .scaleAspectFit
            image = pickedImage
            self.sdkManager.startEditingImage(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
