import UIKit
import Foundation
import BNBSdkApi
import BNBSdkCore

class PhotoEditingViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    private let player = Player()
    private let photo = Photo()

    private let imagePicker = UIImagePickerController()
    
    private var makeup: BNBEffect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.effectPlayer.effectManager()?.add(self)
        player.use(input: photo, outputs: [effectView])
        
        // Load Makeup effect from `effects` folder
        makeup = player.load(effect: "Makeup")
        
        // Initialize Makeup effect with the Hair.color and the Eyes.color
        makeup?.evalJs("Hair.color('1.0 0.0 0.0 0.5');", resultCallback: nil)
        makeup?.evalJs("Eyes.color('1.0 0.0 0.0 0.5');", resultCallback: nil)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.effectPlayer.effectManager()?.remove(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func selectImage(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func hairValueChanged(_ sender: UISlider) {
        makeup?.evalJs("Hair.color('1.0 \(sender.value / 10) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func eyesValueChanged(_ sender: UISlider) {
        makeup?.evalJs("Eyes.color('1.0 \(sender.value / 10) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoEditingViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.effectView.contentMode = .scaleAspectFit
            self.photo.take(from: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoEditingViewController: BNBErrorListener {
    func onError(_ domain: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.selectImageButton.isHidden = true
            self?.dismiss(animated: true, completion: nil)
            let alert = UIAlertController(
                title: "Can't load the Makeup effect",
                message: "This demo requires the Makeup effect in the 'effects' folder. You can find information about how to get the effect in README.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: false, completion: nil)
        }
    }
}
