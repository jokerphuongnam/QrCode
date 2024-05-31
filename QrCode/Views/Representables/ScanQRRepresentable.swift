//
//  ScanQRRepresentable.swift
//  QrCode
//
//  Created by P. Nam on 31/05/2024.
//

import SwiftUI
import AVFoundation

struct ScanQRRepresentable: UIViewControllerRepresentable {
    @Binding private var code: String
    
    init(code: Binding<String>) {
        self._code = code
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            return viewController
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        context.coordinator.previewLayer = previewLayer
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue(label: "ScanQR", qos: .background).async {
            captureSession.startRunning()
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.previewLayer?.frame = uiViewController.view.layer.bounds
    }
}

extension ScanQRRepresentable {
    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private var start: TimeInterval?
        private let parent: ScanQRRepresentable
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(parent: ScanQRRepresentable) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let now = Date().timeIntervalSince1970
            if let start {
                if now - start > 0.3 {
                    self.start = now
                    handler(didOutput: metadataObjects)
                }
            } else {
                start = now
                handler(didOutput: metadataObjects)
            }
        }
        
        private func handler(didOutput metadataObjects: [AVMetadataObject]) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.code = stringValue
            }
        }
    }
}

#Preview {
    ScanQRRepresentable(code: .constant(""))
}
