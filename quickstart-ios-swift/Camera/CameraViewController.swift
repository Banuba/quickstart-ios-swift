import UIKit
import BanubaSdk
import BanubaEffectPlayer

class CameraViewController: UIViewController {
    
    @IBOutlet weak var effectView: EffectPlayerView!
    
    private var sdkManager = BanubaSdkManager()
    private let config = EffectPlayerConfiguration(renderMode: .video)
    private var labels_view: UIView?
    
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

        var rec_result = fD.getFrxRecognitionResult()
        var faces = rec_result?.getFaces()
        var landmarks_t = faces?[0].getLandmarks()
        
        if (landmarks_t?.count ?? 0 > 0){
            guard var rec_res_t = rec_result?.getTransform() else { return }

            let init_rect = rec_res_t.fullRoi//BNBPixelRect(x:0, y:0, w:Int32(config.renderSize.height), h:Int32(config.renderSize.width))

            var tsrc = BNBTransformation.makeData(rec_res_t.basisTransform)
            guard var rsrc = tsrc?.inverseJ()?.transform(init_rect) else { return } // lms rect to common basis
            
            guard var tdst = BNBTransformation.makeRects(rsrc, targetRect: BNBPixelRect(x:0, y:0, w:screen_width, h:screen_height), rot: BNBRotation.deg0, flipX: false, flipY: false) else { return }

            guard var t = tsrc?.inverseJ()?.chainRight(tdst) else { return } // (lms -> common) >> (common -> (720, 1280))

            guard var landmarks = landmarks_t else { return }

            print("Landmark size: ", landmarks.count);
            var landmarks_points: [CGPoint] = []
            for i in 0 ..< (landmarks.count/2) {
               // print("Number: ", i,   " X: ", landmarks[i * 2], " Y: ", landmarks[2 * i + 1] );
                //landmarks_points.append( CGPoint(x:landmarks[i * 2], y:landmarks[2 * i + 1]) );
                let x_coord = landmarks[i * 2]
                let y_coord = landmarks[2 * i + 1]
                let point = CGPoint(x: CGFloat(x_coord), y: CGFloat(y_coord))
               // landmarks_points.append(point)
                
                let bnb_point = t.transformPoint(BNBPoint2d(x: Float(point.x), y: Float(point.y)))
                landmarks_points.append(CGPoint(x: CGFloat(bnb_point.x), y: CGFloat(bnb_point.y)))
                //print("Number: ", i,   " X: ", landmarks[i])
            }
        
        
            print("landmarks_points size: ", landmarks_points.count);
            //counter = 0
            var path = CGMutablePath();
            let radius = 1;

            var i = 0
            for landmarks_point in landmarks_points {
               // print("Number: ", i,   " X: ", landmarks_point.x, " Y: ", landmarks_point.y);
                path.addEllipse(in: CGRect(x: Int(landmarks_point.x) - radius,
                                           y: Int(landmarks_point.y) - radius,
                                       width: 2 * radius,
                                      height: 2 * radius))
                i += 1
                
            }
            
            let shapeLayer = CAShapeLayer()
            //shapeLayer.frame = CGRect(x: 0, y: 0, width: 720, height: 1280)
            //shapeLayer.path = points_path.cgPath
            shapeLayer.path = path;
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 1

            // Add that `CAShapeLayer` to your view's layer:
            DispatchQueue.main.async { [weak self] in
                var label_count = 1
                
                if (self?.labels_view == nil) {
                    self?.labels_view = UIView()
                } else {
                    self?.labels_view?.removeFromSuperview()
                    self?.labels_view = UIView()
                }
                
                for landmarks_point in landmarks_points {
                    
                    let label = UILabel(frame: CGRect(x: Int(landmarks_point.x) - radius - 11,
                                                      y: Int(landmarks_point.y) - 2 * radius,
                                                      width: 15,
                                                      height: 10))
                    label.textAlignment = .left
                    label.textColor = UIColor.red
                    label.text = "\(label_count)"
                    label.adjustsFontSizeToFitWidth = false
                    label.font = label.font.withSize(8)
                    label_count += 1
                    
                    self?.labels_view?.addSubview(label)
                }
                if (self?.labels_view != nil){
                    self?.labels_view?.layer.addSublayer(shapeLayer)
                    self?.effectView.addSubview((self?.labels_view!)!)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                if (self?.labels_view != nil) {
                    self?.labels_view?.removeFromSuperview()
                }
            }
        }
        
    }
}
