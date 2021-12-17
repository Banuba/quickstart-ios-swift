import UIKit
import BanubaSdk
import BanubaEffectPlayer

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    private var labelsView: UIView?
    
    private var screenWidth: Int32 = 0
    private var screenHeight: Int32 = 0
    
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
        screenWidth = Int32(effectView.frame.size.width)
        screenHeight = Int32(effectView.frame.size.height)
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
        let landmarksCoordinates = faces?[0].getLandmarks() // Array of NSNumber with size of 2 * landmarks number.
                                                            // The first value responds to X coord of the first landmark
                                                            // The second value responds to Y coord of the first landmark
        
        guard let landmarks = landmarksCoordinates else { return }
        if landmarks.count == 0 {
            // if there are no landmarks we will just remove last labelsView from the screen
            if self.labelsView != nil {
                DispatchQueue.main.async { [weak self] in
                    self?.labelsView?.removeFromSuperview()
                }
            }
        } else {
            // get transformation from FRX (Camera) coordinates to Screen coordinates
            // see https://docs.banuba.com/face-ar-sdk/core/transformations
            let screenRect = BNBPixelRect(x:0, y:0, w:screenWidth, h:screenHeight)
            guard let frxResultTransformation = recognitionResult?.getTransform(),
            let commonToFrxResult = BNBTransformation.makeData(frxResultTransformation.basisTransform),
            let commonRect = commonToFrxResult.inverseJ()?.transform(frxResultTransformation.fullRoi),
            let commonToScreen = BNBTransformation.makeRects(commonRect,
                                                             targetRect: screenRect,
                                                             rot: BNBRotation.deg0, flipX: false, flipY: false),
            let FrxResultToCommon = commonToFrxResult.inverseJ(),
            let frxResultToScreen = FrxResultToCommon.chainRight(commonToScreen)  else { return }

            //create points from transformed coordinates
            var landmarksPoints: [CGPoint] = []
            for i in 0 ..< (landmarks.count / 2) {
                let xCoord = Float(truncating: landmarks[i * 2])
                let yCoord = Float(truncating: landmarks[2 * i + 1])
                let pointBeforeTransformation = BNBPoint2d(x: xCoord, y: yCoord)
                
                let pointAfterTransformation = frxResultToScreen.transformPoint(pointBeforeTransformation)
                landmarksPoints.append(CGPoint(x: CGFloat(pointAfterTransformation.x),
                                               y: CGFloat(pointAfterTransformation.y)))
            }
            
            //make points on layer
            let pointsLayer = CAShapeLayer()
            let pointsRadius = 1
            makePoints(layer: pointsLayer, landmarksPoints: landmarksPoints, radius: pointsRadius)
            
            //process visualisation
            DispatchQueue.main.async { [weak self] in
                if self?.labelsView == nil {
                    self?.labelsView = UIView()
                } else {
                    self?.labelsView?.removeFromSuperview() //remove previous labelsView
                    self?.labelsView = UIView()
                }
                
                self?.drawLabelsOnLabelsView(landmarksPoints: landmarksPoints, radius: pointsRadius)
                self?.labelsView?.layer.addSublayer(pointsLayer)
                
                if let view = self?.labelsView {
                    self?.effectView.addSubview(view)
                }
            }
        }
    }
    
    func makePoints(layer: CAShapeLayer, landmarksPoints: [CGPoint], radius: Int) {
        let path = CGMutablePath()
        for landmarksPoint in landmarksPoints {
            path.addEllipse(in: CGRect(x: Int(landmarksPoint.x) - radius,
                                       y: Int(landmarksPoint.y) - radius,
                                   width: 2 * radius,
                                  height: 2 * radius))
        }
        
        CATransaction.begin()
        layer.path = path
        layer.strokeColor = UIColor.red.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        CATransaction.commit()
    }
    
    func drawLabelsOnLabelsView(landmarksPoints: [CGPoint], radius: Int) {
        var labelCounter = 1
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
            
            self.labelsView?.addSubview(label)
        }
    }
}
