import UIKit
import BNBSdkApi
import BNBSdkCore

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var galleryImage: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    private var sdkManager = BanubaSdkManager()
    private var gpuDevice: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var offscreenLayer = CAMetalLayer()
    
    func getSurface() -> BNBSurfaceData {
        guard let device = MTLCreateSystemDefaultDevice() else
        {
            fatalError("GPU device not available")
        }
        guard let queue = device.makeCommandQueue() else {
            fatalError("GPU command queue not available")
        }
        self.gpuDevice = device
        self.commandQueue = queue
        let data = BNBSurfaceData.init(
            gpuDevicePtr: Int64(Int(bitPattern: Unmanaged.passUnretained(gpuDevice).toOpaque())),
            commandQueuePtr: Int64(Int(bitPattern: Unmanaged.passUnretained(commandQueue).toOpaque())),
            surfacePtr: Int64(Int(bitPattern: Unmanaged.passUnretained(offscreenLayer).toOpaque()))
        )
        return data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkManager.setup(configuration: EffectPlayerConfiguration())
        sdkManager.effectManager()?.setRenderSurface(getSurface())
        sdkManager.effectPlayer?.surfaceCreated(720, height: 1280)
        _ = sdkManager.loadEffect("TrollGrandma", synchronous: true)

        // Run 1 draw call on 1x1 image to prepare render pipline
        sdkManager.processImageData(
            UIImage(bgraDataNoCopy: Data(count: 4) as NSData, width: 1, height: 1)!,
            completion: {(_: UIImage?) in})
            
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
                    let alert = UIAlertController(
                        title: "Photo Processing",
                        message: "Your photo is ready",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(
                        title: "OK",
                        style: .default,
                        handler: nil)
                    )
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
