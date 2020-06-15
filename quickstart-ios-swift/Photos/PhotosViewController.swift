import UIKit
import BanubaSdk

class PhotosViewController: UIViewController {
    
    private let imagePicker = UIImagePickerController()
    private var sdkManager = BanubaSdkManager()
    @IBOutlet weak var galleryImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sdkManager.setup(configuration: EffectPlayerConfinguration(renderMode: .photo))
        sdkManager.effectPlayer?.surfaceCreated(720, height: 1280)
        sdkManager.loadEffect("UnluckyWitch", synchronous: true)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    deinit {
        sdkManager.destroyEffectPlayer()
    }
    
    @IBAction func openPhoto(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func closeGallery(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotosViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.galleryImage.contentMode = .scaleAspectFit
            self.sdkManager.processImageData(pickedImage) { procImage in
                DispatchQueue.main.async {
                    self.galleryImage.image = procImage
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
