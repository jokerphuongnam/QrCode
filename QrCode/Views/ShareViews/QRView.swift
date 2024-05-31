//
//  QRView.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI

struct QRView: View {
    @State private var imageState: DataState<UIImage> = .loading
    @State private var highImage: UIImage?
    @Binding private var textGenerate: String
    @Binding private var backgroundImage: UIImage?
    
    init(_ textGenerate: Binding<String>, _ backgroundImage: Binding<UIImage?>) {
        self._textGenerate = textGenerate
        self._backgroundImage = backgroundImage
    }
    
    @ViewBuilder var body: some View {
        switch self.imageState {
        case .loading:
            GeometryReader { proxy in
                ZStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if let backgroundImage {
                        self.generatePreviewQRCode(backgroundImage: backgroundImage)
                    } else {
                        self.generatePreviewQRCode()
                    }
                }
            }
        case .success(let data):
            GeometryReader { proxy in
                let size = proxy.size
                
                Image(
                    uiImage: { () -> UIImage in
                        if let highImage {
                            return highImage
                        }
                        return data
                    }()
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(.gray, lineWidth: 2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .onAppear {
                    if let backgroundImage {
                        self.generateQRCode(rootImage: data, size: size, backgroundImage: backgroundImage)
                    } else {
                        self.generateQRCode(rootImage: data, size: size)
                    }
                }
                .onChange(of: textGenerate) { oldValue, newValue in
                    self.imageState = .loading
                }
                .onChange(of: backgroundImage) { oldValue, newValue in
                    if !textGenerate.isEmpty {
                        self.imageState = .loading
                    }
                }
            }
        case .error(let error):
            ZStack {
                Text(error?.localizedDescription ?? "Can't load qr")
                    .foregroundColor(.red)
            }
            .onChange(of: textGenerate) { oldValue, newValue in
                self.imageState = .loading
            }
            .onChange(of: backgroundImage) { oldValue, newValue in
                if !textGenerate.isEmpty {
                    self.imageState = .loading
                }
            }
        }
    }
    
    private func generatePreviewQRCode() {
        DispatchQueue(label: "QRCodeGenerator", qos: .background).async {
            let data = textGenerate.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                if let qrCodeImage = filter.outputImage {
                    if let cgImage = CIContext().createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                        DispatchQueue.main.async {
                            self.imageState = .success(data: UIImage(cgImage: cgImage))
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageState = .error(error: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageState = .error(error: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.imageState = .error(error: nil)
                }
            }
        }
    }
    
    private func generatePreviewQRCode(backgroundImage: UIImage) {
        print(backgroundImage)
        DispatchQueue(label: "QRCodeGenerator", qos: .background).async {
            let data = textGenerate.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                if let qrCodeImage = filter.outputImage {
                    if let cgImage = CIContext().createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                        let combinedImage = UIImage(cgImage: cgImage).mixImages(image: backgroundImage, alpha: 0.3)
                        if let combinedImage {
                            DispatchQueue.main.async {
                                self.imageState = .success(data: combinedImage)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.imageState = .error(error: nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageState = .error(error: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageState = .error(error: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.imageState = .error(error: nil)
                }
            }
        }
    }
    
    private func generateQRCode(rootImage: UIImage, size: CGSize) {
        DispatchQueue(label: "QRCodeGenerator", qos: .background).async {
            let data = textGenerate.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                if let qrCodeImage = filter.outputImage {
                    let ratio = rootImage.getRatioImageBySize(size: size)
                    let transform = CGAffineTransform(scaleX: ratio.widthRatio, y: ratio.heightRatio)
                    let scaledQrCodeImage = qrCodeImage.transformed(by: transform)
                    if let cgImage = CIContext().createCGImage(scaledQrCodeImage, from: scaledQrCodeImage.extent) {
                        DispatchQueue.main.async {
                            self.highImage = UIImage(cgImage: cgImage)
                        }
                    }
                }
            }
        }
    }
    
    private func generateQRCode(rootImage: UIImage, size: CGSize, backgroundImage: UIImage) {
        DispatchQueue(label: "QRCodeGenerator", qos: .background).async {
            let data = textGenerate.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("Q", forKey: "inputCorrectionLevel")
                
                if let qrCodeImage = filter.outputImage {
                    let ratio = rootImage.getRatioImageBySize(size: size)
                    let transform = CGAffineTransform(scaleX: ratio.widthRatio, y: ratio.heightRatio)
                    let scaledQrCodeImage = qrCodeImage.transformed(by: transform)
                    if let cgImage = CIContext().createCGImage(scaledQrCodeImage, from: scaledQrCodeImage.extent) {
                        let combinedImage = UIImage(cgImage: cgImage).mixImages(image: backgroundImage, alpha: 0.3)
                        DispatchQueue.main.async {
                            self.highImage = combinedImage
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    QRView(.constant("cxcxxcxcxcc"), .constant(nil))
}
