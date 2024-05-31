//
//  UIKit+extension.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import UIKit

extension UIImage {
    @inlinable func scalePreservingAspectRatio(size: CGSize) -> UIImage {
        scalePreservingAspectRatio(width: size.width, height: size.height)
    }
    
    @inlinable func scalePreservingAspectRatio(width: Int, height: Int) -> UIImage {
        scalePreservingAspectRatio(width: CGFloat(width), height: CGFloat(height))
    }
    
    @inlinable func scalePreservingAspectRatio(width: CGFloat, height: CGFloat) -> UIImage {
        let widthRatio = CGFloat(width) / size.width
        let heightRatio = CGFloat(height) / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: format
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(
                in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                )
            )
        }
        
        return scaledImage
    }
    
    @inlinable func getRatioImageBySize(size: CGSize) -> (widthRatio: CGFloat, heightRatio: CGFloat) {
        getRatioImageBySize(width: size.width, height: size.height)
    }
    
    @inlinable func getRatioImageBySize(width: Int, height: Int) -> (widthRatio: CGFloat, heightRatio: CGFloat) {
        getRatioImageBySize(width: CGFloat(width), height: CGFloat(height))
    }
    
    @inlinable func getRatioImageBySize(width: CGFloat, height: CGFloat) -> (widthRatio: CGFloat, heightRatio: CGFloat) {
        (
            CGFloat(width) / size.width,
            CGFloat(height) / size.height
        )
    }
    
    @inlinable func resize(targetSize: CGSize) -> UIImage {
        let newSize = targetSize
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UIImage {
    func mixImages(image: UIImage, alpha: CGFloat) -> UIImage? {
        guard let cgImage1 = self.cgImage else {
            return nil
        }
        
        let resizeImage = image.resize(targetSize: self.size)
        
        guard let cgImage2 = image.cgImage else {
            return nil
        }
        
        let width = cgImage1.width
        let height = cgImage2.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bytesPerComponent = bitsPerComponent / 8
        
        var pixelData1 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        var pixelData2 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context1 = CGContext(
            data: &pixelData1,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ),
              let context2 = CGContext(
                data: &pixelData2,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
              ) else {
            return nil
        }
        
        context1.draw(cgImage1, in: CGRect(x: 0, y: 0, width: width, height: height))
        context2.draw(cgImage2, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Mix pixel data
        var blendedPixelData = [UInt8]()
        for i in 0..<pixelData1.count {
            let pixelValue1 = CGFloat(pixelData1[i]) / 255.0
            let pixelValue2 = CGFloat(pixelData2[i]) / 255.0
            let blendedPixelValue = UInt8((alpha * pixelValue1 + (1.0 - alpha) * pixelValue2) * 255.0)
            blendedPixelData.append(blendedPixelValue)
        }
        
        guard let blendedCGImage = context1.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: blendedCGImage)
    }
}
