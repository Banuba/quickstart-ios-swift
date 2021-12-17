import UIKit
import BanubaSdk
import BanubaEffectPlayer

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    private var labelsView: UIView?
    
    private var screen_width: Int32 = 0
    private var screen_height: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effectView.layoutIfNeeded()
        sdkManager.setup(configuration: config)
        setUpRenderSize()
        effectView?.effectPlayer = sdkManager.effectPlayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListeners()
        sdkManager.input.startCamera()
        _ = sdkManager.loadEffect("test_Lips", synchronous: true)
        sdkManager.startEffectPlayer()
        screen_width = Int32(effectView.frame.size.width)
        screen_height = Int32(effectView.frame.size.height)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
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
        }, completion: nil)
    }
    
    private func addListeners() {
        sdkManager.effectPlayer?.add(self as BNBFrameDataListener)
    }
    
    private func removeListeners() {
        sdkManager.effectPlayer?.remove(self as BNBFrameDataListener)
    }
    
    private func setUpRenderTarget() {
        guard let effectView = self.effectView.layer as? CAEAGLLayer else { return }
        sdkManager.setRenderTarget(layer: effectView, playerConfiguration: nil)
        sdkManager.startEffectPlayer()
    }
    
    private func setUpRenderSize() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            config.orientation = .deg90
            config.renderSize = CGSize(width: 720, height: 1280)
            sdkManager.autoRotationEnabled = false
            setUpRenderTarget()
        case .portraitUpsideDown:
            config.orientation = .deg270
            config.renderSize = CGSize(width: 720, height: 1280)
            setUpRenderTarget()
        case .landscapeLeft:
            config.orientation = .deg180
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        case .landscapeRight:
            config.orientation = .deg0
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        default:
            setUpRenderTarget()
        }
    }
    
    @IBAction func closeCamera(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: BNBFrameDataListener {
    func onFrameDataProcessed(_ frameData: BNBFrameData?) {
        guard let fD = frameData else { return }

        let recognitionResult = fD.getFrxRecognitionResult()
        let faces = recognitionResult?.getFaces()
        let landmarks_t = faces?[0].getLandmarks()
        
        if (landmarks_t?.count ?? 0 == 0){
            DispatchQueue.main.async { [weak self] in
                if (self?.labelsView != nil) {
                    self?.labelsView?.removeFromSuperview()
                }
            }
        } else {
            
            guard let rec_res_t = recognitionResult?.getTransform() else { return }
            let tsrc = BNBTransformation.makeData(rec_res_t.basisTransform)
            guard let rsrc = tsrc?.inverseJ()?.transform(rec_res_t.fullRoi) else { return }
            guard let tdst = BNBTransformation.makeRects(rsrc, targetRect: BNBPixelRect(x:0, y:0, w:screen_width, h:screen_height), rot: BNBRotation.deg0, flipX: false, flipY: false) else { return }
            guard let t = tsrc?.inverseJ()?.chainRight(tdst) else { return }

            guard let landmarks = landmarks_t else { return }

            var landmarksPoints: [CGPoint] = []
            for i in 0 ..< (landmarks.count/2) {
                let x_coord = Float(truncating: landmarks[i * 2])
                let y_coord = Float(truncating: landmarks[2 * i + 1])
                let pointBeforeTransformation = BNBPoint2d(x: x_coord, y: y_coord)
                
                let pointAfterTransformation = t.transformPoint(pointBeforeTransformation)
                landmarksPoints.append(CGPoint(x: CGFloat(pointAfterTransformation.x), y: CGFloat(pointAfterTransformation.y)))
            }
        
            let path = CGMutablePath();
            let radius = 1;
            for landmarksPoint in landmarksPoints {
                path.addEllipse(in: CGRect(x: Int(landmarksPoint.x) - radius,
                                           y: Int(landmarksPoint.y) - radius,
                                       width: 2 * radius,
                                      height: 2 * radius))
            }
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path;
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 1

            // Add that `CAShapeLayer` to your view's layer:
            DispatchQueue.main.async { [weak self] in
                var labelCounter = 1
                
                if (self?.labelsView == nil) {
                    self?.labelsView = UIView()
                } else {
                    self?.labelsView?.removeFromSuperview()
                    self?.labelsView = UIView()
                }
                
                for landmarksPoint in landmarksPoints {
                    
                    let label = UILabel(frame: CGRect(x: Int(landmarksPoint.x) - radius - 11,
                                                      y: Int(landmarksPoint.y) - 2 * radius,
                                                      width: 15,
                                                      height: 10))
                    label.textAlignment = .left
                    label.textColor = UIColor.red
                    label.text = "\(labelCounter)"
                    label.adjustsFontSizeToFitWidth = false
                    label.font = label.font.withSize(8)
                    labelCounter += 1
                    
                    self?.labelsView?.addSubview(label)
                }
                if (self?.labelsView != nil){
                    self?.labelsView?.layer.addSublayer(shapeLayer)
                    self?.effectView.addSubview((self?.labelsView!)!)
                }
            }
        }
    }
}
