import UIKit
import AVKit
import BNBSdkApi

class VideoViewController: UIViewController {
    
    @IBOutlet weak var videoProcessingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var openVideoButton: UIButton!
    
    private let player = Player()
    private let stream = BNBSdkApi.Stream()
    private let videoProcessing = VideoProcessing()
    private let avPlayer = AVPlayer()
    private let videoPickerVC = UIImagePickerController()
    private var avPlayerVC: AVPlayerViewController? {
        return children.compactMap {
            $0 as? AVPlayerViewController
        }.first
    }
    
    private var lastPixelBuffer: CVPixelBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pixelBufferOutput = PixelBuffer(onPresent: { [weak self] buffer in
            guard let buffer = buffer else { return }
            // save last processed pixel buffer
            self?.lastPixelBuffer = buffer
        })
        
        // use manual render mode to control when pixel buffer should be presented
        player.renderMode = .manual
        player.use(input: stream, outputs: [pixelBufferOutput])
        _ = player.load(effect: "TrollGrandma", sync: true)
        
        avPlayerVC?.view.isHidden = true
        videoProcessingIndicator.isHidden = true
        videoProcessing.delegate = self
        videoPickerVC.delegate = self
        videoPickerVC.sourceType = .photoLibrary
        videoPickerVC.mediaTypes = ["public.movie"]
        present(videoPickerVC, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToBackground() {
        videoProcessingIndicator.stopAnimating()
        videoProcessingIndicator.isHidden = true
        videoProcessing.cancelProcessing()
    }
    
    private func processPixelBuffer(_ pixelBuffer: CVPixelBuffer, with presentationTime: CMTime) -> CVPixelBuffer {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var outputPixelBuffer: CVPixelBuffer!
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &outputPixelBuffer)
        assert(status == kCVReturnSuccess)
        return outputPixelBuffer
    }
}

extension VideoViewController {
    
    @IBAction func openVideoButtonGotTapEvent(_ sender: Any) {
        present(videoPickerVC, animated: true)
    }
    
    @IBAction func backButtonGotTapEvent(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension VideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let url = info[.mediaURL] as? URL else {
            picker.dismiss(animated: true)
            return
        }
        picker.dismiss(animated: true)
        avPlayerVC?.player = avPlayer
        avPlayerVC?.view.isHidden = true
        videoProcessingIndicator.isHidden = false
        videoProcessingIndicator.startAnimating()
        videoProcessing.cancelProcessing()
        videoProcessing.startProcessing(url: url)
    }
}

extension VideoViewController: VideoProcessingDelegate {
    func videoProcessingNeedsSample(for pixelBuffer: CVPixelBuffer, presentationTime: CMTime) -> CVPixelBuffer {
        // push input pixel buffer for processing
        stream.push(pixelBuffer: pixelBuffer)
        
        // process input pixel buffer and present result manually
        // NOTE: lastPixelBuffer will be filled during presentation inside the render call (see viewDidLoad)
        _ = player.render()
        
        guard let outPixelBuffer = lastPixelBuffer else { fatalError("pixel buffer is nil") }
        return outPixelBuffer
    }
    
    func videoProcessingDidCompleteProcessing(url: URL) {
        videoProcessingIndicator.stopAnimating()
        avPlayerVC?.view.isHidden = false
        avPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        avPlayer.play()
        let alert = UIAlertController(title: "Video Processed", message: "Would you like to save it in gallery?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.relativePath) {
                UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, nil, nil, nil)
            }
        })
        present(alert, animated: true, completion: nil)
    }
}
