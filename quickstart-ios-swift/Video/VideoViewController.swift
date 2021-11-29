import UIKit
import AVKit
import BanubaSdk

class VideoViewController: UIViewController {
    
    @IBOutlet weak var videoProcessingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var openVideoButton: UIButton!
    
    private var sdkManager = BanubaSdkManager()
    private let videoProcessing = VideoProcessing()
    private let player = AVPlayer()
    private let videoPickerVC = UIImagePickerController()
    private var playerVC: AVPlayerViewController? {
        return children.compactMap {
            $0 as? AVPlayerViewController
        }.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerVC?.view.isHidden = true
        videoProcessingIndicator.isHidden = true
        videoProcessing.delegate = self
        videoPickerVC.delegate = self
        videoPickerVC.sourceType = .photoLibrary
        videoPickerVC.mediaTypes = ["public.movie"]
        present(videoPickerVC, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        sdkManager.destroyEffectPlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToBackground() {
        videoProcessingIndicator.stopAnimating()
        videoProcessingIndicator.isHidden = true
        videoProcessing.cancelProcessing()
        sdkManager.destroyEffectPlayer()
    }
    
    private func createEffectPlayerView(videoNaturalSize size: CGSize) -> EffectPlayerView {
        let scale = UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: Int(size.width / scale), height: Int(size.height / scale))
        let epView = EffectPlayerView(frame: frame)
        epView.isMultipleTouchEnabled = true
        epView.layer.contentsScale = UIScreen.main.scale
        return epView
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
        playerVC?.player = player
        playerVC?.view.isHidden = true
        videoProcessingIndicator.isHidden = false
        videoProcessingIndicator.startAnimating()
        videoProcessing.cancelProcessing()
        sdkManager.destroy()
        guard let videoNaturalSize = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first?.naturalSize else {return}
        let epView = createEffectPlayerView(videoNaturalSize: videoNaturalSize)
        sdkManager.setup(configuration: EffectPlayerConfiguration(renderMode: .video))
        sdkManager.setRenderTarget(view: epView, playerConfiguration: nil)
        _ = sdkManager.loadEffect("TrollGrandma", synchronous: true)
        sdkManager.startVideoProcessing(width: UInt(videoNaturalSize.width), height: UInt(videoNaturalSize.height))
        videoProcessing.startProcessing(url: url)
    }
}

extension VideoViewController: VideoProcessingDelegate {
    func videoProcessingNeedsSample(for pixelBuffer: CVPixelBuffer, presentationTime: CMTime) -> CVPixelBuffer {
        let nanoSeconds = Int64(presentationTime.seconds * 1E9)
        let outputPixelBuffer = processPixelBuffer(pixelBuffer, with: presentationTime)
        sdkManager.processVideoFrame(from: pixelBuffer, to: outputPixelBuffer, timeNs: nanoSeconds, iterations: 1)
        return outputPixelBuffer
    }
    
    func videoProcessingDidCompleteProcessing(url: URL) {
        videoProcessingIndicator.stopAnimating()
        playerVC?.view.isHidden = false
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        let alert = UIAlertController(
            title: "Video Processing",
            message: "Your video is ready",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        )
        present(alert, animated: true, completion: nil)
    }
}
