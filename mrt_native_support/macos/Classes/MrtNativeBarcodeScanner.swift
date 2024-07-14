import AVFoundation
import CoreImage
import Cocoa
import FlutterMacOS

class BarcodeScanner: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrDetector: CIDetector!
    var channel: FlutterMethodChannel?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    @available(macOS 10.14, *)
    func checkCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    func canStartBarcodeScanner() -> Bool {
        var platformSupported = false
        if #available(macOS 10.14, *) {
            platformSupported = true
        }
        
        var hasVideoDevice = false
        if platformSupported {
            hasVideoDevice = AVCaptureDevice.default(for: .video) != nil
        }
        
        return platformSupported && hasVideoDevice
    }

    @available(macOS 10.14, *)
    func startBarcodeScanner(result: FlutterResult, args: [String: Any]) {
        if(captureSession != nil){
          result(FlutterError(code: "invalid_arguments", message: "Service already running.", details: nil))
          return;
        }
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            result(FlutterError(code: "CAMERA_ERROR", message: "No camera available", details: nil))
            return
        }
        let width = args["width"] as! Double
        let height = args["height"] as! Double
        let x = args["x"] as! Double
        let y = args["y"] as! Double
        let frame = CGRect(x: x, y: y, width: width, height: height)

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession?.addOutput(videoOutput)

            if let viewController = NSApplication.shared.windows.first?.contentViewController {
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = frame
                viewController.view.layer?.addSublayer(videoPreviewLayer!)
                captureSession?.startRunning()
                result(nil)
            } else {
                result(FlutterError(code: "VIEW_CONTROLLER_ERROR", message: "ViewController not found", details: nil))
            }
        } catch {
            stopBarcodeScanner()
            result(FlutterError(code: "CAMERA_ERROR", message: "Camera setup failed", details: error.localizedDescription))
        }
    }

    @available(macOS 10.14, *)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let features = qrDetector.features(in: ciImage)

        for feature in features {
            if let qrCodeFeature = feature as? CIQRCodeFeature, let messageString = qrCodeFeature.messageString {
                DispatchQueue.main.async {
                    let data: NSDictionary = [
                        "type": "success",
                        "message": messageString,
                    ]
                    self.channel?.invokeMethod("onBarcodeScanned", arguments: data)
                }
            }
        }
    }

    @available(macOS 10.14, *)
    func stopBarcodeScanner() {
        if let session = captureSession {
            if session.isRunning {
                session.stopRunning()
            }
            for input in session.inputs {
                session.removeInput(input)
            }
            for output in session.outputs {
                session.removeOutput(output)
            }
            if let previewLayer = videoPreviewLayer {
                previewLayer.removeFromSuperlayer()
                videoPreviewLayer = nil
            }
        }
        captureSession = nil
        qrDetector = nil
    }
}
