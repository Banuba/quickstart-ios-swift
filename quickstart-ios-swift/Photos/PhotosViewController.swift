import UIKit
import BNBSdkApi
import BNBSdkCore

class PhotosViewController: UIViewController {
    @IBOutlet weak var galleryImage: UIImageView!

    private let imagePicker = UIImagePickerController()
    
    // `Player` process frames from the input and render them into the outputs
    private let player = Player()
    
    // Input photo
    private let photo = Photo()
    
    // Current effect
    private var effect: BNBEffect?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Change render mode to manual, to exactly control when player will render
        player.renderMode = .manual
        
        // Load effect from `effects` folder synchronously
        effect = player.load(effect: "TrollGrandma", sync: true)

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
            // Create the frame output with completion, when frame will be rendered
            let imageOutput = Frame<UIImage>() { image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    // Show processed image
                    self.galleryImage.contentMode = .scaleAspectFit
                    self.galleryImage.image = image
                    
                    // Propose to save processed image
                    let alert = UIAlertController(title: "Photo Processed", message: "Would you like to save it in gallery?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // Connect photo input and frame output to the player
            player.use(input: photo)
            player.use(outputs: [imageOutput])
            
            // Take photo for processing from the picked image
            photo.take(from: pickedImage)
            
            // Render frame and check the result
            guard player.render() else { fatalError("Rendering Error") }
        }
        dismiss(animated: true, completion: nil)
    }
}
