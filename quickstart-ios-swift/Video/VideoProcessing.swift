import AVFoundation

private struct Defaults {
    static let outputVideoURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mov")
}

protocol VideoProcessingDelegate: AnyObject {
    func videoProcessingNeedsSample(for pixelBuffer: CVPixelBuffer, presentationTime: CMTime) -> CVPixelBuffer
    func videoProcessingDidCompleteProcessing(url: URL)
}

class VideoProcessing {
    
    private let videoProcessingQueue = DispatchQueue(label: "videoProcessingQueue", qos: .userInitiated)
    
    private var assetWriter: AVAssetWriter?
    private var assetReader: AVAssetReader?
    
    private var isProcessing = false
    
    weak var delegate: VideoProcessingDelegate?
    
    func startProcessing(url: URL) {
        cancelProcessing()
        try? FileManager.default.removeItem(at: Defaults.outputVideoURL)
        
        let asset = AVAsset(url: url)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        
        let videoReaderSettings: [String:Any] =  [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        let videoSettings:[String:Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width
        ]
        
        let assetReader = try! AVAssetReader(asset: asset)
        self.assetReader = assetReader
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        
        if assetReader.canAdd(assetReaderVideoOutput){
            assetReader.add(assetReaderVideoOutput)
        } else {
            fatalError("Couldn't add video output reader")
        }
        
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        
        let assetWriter = try! AVAssetWriter(outputURL: Defaults.outputVideoURL, fileType: AVFileType.mov)
        self.assetWriter = assetWriter
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
        
        assetWriter.add(videoInput)
        assetWriter.startWriting()
        assetReader.startReading()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        isProcessing = true
        
        videoInput.requestMediaDataWhenReady(on: videoProcessingQueue) { [weak self] in
            guard let self = self else {
                return
            }
            while videoInput.isReadyForMoreMediaData {
                guard let sample = assetReaderVideoOutput.copyNextSampleBuffer() else {
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.closeReaderAndWriter()
                    }
                    break
                }
                autoreleasepool {
                    let pixelBuffer = CMSampleBufferGetImageBuffer(sample)!
                    let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
                    if let processedPixelBuffer = self.delegate?.videoProcessingNeedsSample(for: pixelBuffer, presentationTime: presentationTime) {
                        adaptor.append(processedPixelBuffer, withPresentationTime: presentationTime)
                    }
                }
            }
        }
    }
    
    func closeReaderAndWriter() {
        guard !isProcessing else { return }
        assetWriter?.finishWriting {
            DispatchQueue.main.async {
                self.delegate?.videoProcessingDidCompleteProcessing(url: Defaults.outputVideoURL)
            }
        }
        assetReader?.cancelReading()
    }
    
    func cancelProcessing() {
        assetWriter?.cancelWriting()
        assetReader?.cancelReading()
        assetReader = nil
        assetWriter = nil
    }
}
