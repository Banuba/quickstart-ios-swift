import UIKit
import BNBSdkApi
import BNBSdkCore

class PhotosViewController: UIViewController {
    @IBOutlet weak var galleryImage: UIImageView!

    private let imagePicker = UIImagePickerController()
    
    private let player = Player()
    private let photo = Photo()

    override func viewDidLoad() {
        super.viewDidLoad()

        player.use(input: photo)
        _ = player.load(effect: "TrollGrandma", sync: true)

        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
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

            let imageOutput = Frame<UIImage>() { image in
                self.player.use(outputs: [])
                if let image = image {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Photo Processing", message: "Your photo is ready", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true) {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                    }
                }
            }
            player.use(outputs: [imageOutput])

            photo.take(from: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
