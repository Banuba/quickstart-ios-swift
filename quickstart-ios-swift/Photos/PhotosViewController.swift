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
            // create the frame output with completion handler, when frame will be presented
            let imageOutput = Frame<UIImage>() { image in
                guard let image = image else { return }
                
                // reset player outputs to stop presenting
                // NOTE: to avoid this, `player.renderMode = .manual` can be used
                self.player.use(outputs: [])
                
                DispatchQueue.main.async {
                    // show processed image
                    self.galleryImage.contentMode = .scaleAspectFit
                    self.galleryImage.image = image
                    
                    // propose to save processed image
                    let alert = UIAlertController(title: "Photo Processed", message: "Would you like to save it in gallery?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // NOTE: order is important here: push image to input first, use frame output second,
            // else previously pushed image can be processed instead
            
            // take photo for processing from the picked image
            photo.take(from: pickedImage)
            
            // use frame output to present, completion will be fired after that
            player.use(outputs: [imageOutput])
        }
        dismiss(animated: true, completion: nil)
    }
}
