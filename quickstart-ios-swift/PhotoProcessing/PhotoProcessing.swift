import UIKit
import Foundation
import BNBSdkApi

class PhotoProcessingController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    private let player = Player()
    private let photo = Photo()

    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        player.use(input: photo, outputs: [effectView])
        
        if let _ = player.load(effect: "Makeup", sync: true) {
            // initialize Makeup effect with the Hair.color and the Eyes.color
            player.effect?.evalJs("Hair.color('1.0 0.0 0.0 0.5'); Eyes.color('1.0 0.0 0.0 0.5');", resultCallback: nil)

            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        } else {
            // can not load Makeup effect
            let alert = UIAlertController(
                title: "Can't load the Makeup effect",
                message: "This view requires the Makeup effect in the 'effects' folder. You can find information about how to get the effect in README.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction( title: "OK", style: .default, handler: nil))
            present(alert, animated: false, completion: nil)
            selectImageButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func selectImage(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func hairValueChanged(_ sender: UISlider) {
        player.effect?.evalJs("Hair.color('1.0 \(sender.value / 10) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func eyesValueChanged(_ sender: UISlider) {
        player.effect?.evalJs("Eyes.color('1.0 \(sender.value / 10) 0.0 0.5')", resultCallback: nil)
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoProcessingController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.effectView.contentMode = .scaleAspectFit
            self.photo.take(from: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
