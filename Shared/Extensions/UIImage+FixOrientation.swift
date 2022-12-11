//
//  UIImage+FixOrientation.swift
//  MediaBook
//
//  Created by deeje cooley on 5/27/22.
//

import UIKit

extension CGImage {
    
    func rotated(for imageOrientation: UIImage.Orientation, with size: CGSize, in colorSpace: CGColorSpace) -> CGImage {
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        if imageOrientation == .down || imageOrientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if imageOrientation == .left || imageOrientation == .leftMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }
        
        if imageOrientation == .right || imageOrientation == .rightMirrored {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0))
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                  bitsPerComponent: bitsPerComponent, bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo.rawValue)
        else {
            return self
        }
        
        ctx.concatenate(transform)
        
        if [.left, .leftMirrored, .right, .rightMirrored].contains(imageOrientation) {
            ctx.draw(self, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        } else {
            ctx.draw(self, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let resultImage = ctx.makeImage() else { return self }
        
        return resultImage
    }
    
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        guard let cgImage, let colorSpace = cgImage.colorSpace else {
            return self
        }
        
        let resultImage = cgImage.rotated(for: imageOrientation, with: size, in: colorSpace)
        
        return UIImage(cgImage: resultImage)
    }
}
