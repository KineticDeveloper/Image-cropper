//
//  ExtensionShapePreview.swift
//  Image-cropper
//
//  Created by P-THY on 6/1/22.
//

import UIKit


extension UIView {
    
    func ICImageResourcePath(_ fileName: String) -> UIImage? {
        let bundle = Bundle(for: ShapePreviewVC.self)
        return UIImage(named: fileName, in: bundle, compatibleWith: nil)
    }
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
       ///
       /// - Returns: `self` as a 1x1 `UIImage`.
       func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 0.5))
           setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 0.5))
           let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
           UIGraphicsEndImageContext()
           return image
       }

}

extension UIImage {
    class func outlinedEllipse(size: CGSize, color: UIColor, lineWidth: CGFloat = 1.0) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        context.addEllipse(in: rect)
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageCropped(toRect rect: CGRect) -> UIImage {
        let rad: (Double) -> CGFloat = { deg in
            return CGFloat(deg / 180.0 * .pi)
        }
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            let rotation = CGAffineTransform(rotationAngle: rad(90))
            rectTransform = rotation.translatedBy(x: 0, y: -size.height)
        case .right:
            let rotation = CGAffineTransform(rotationAngle: rad(-90))
            rectTransform = rotation.translatedBy(x: -size.width, y: 0)
        case .down:
            let rotation = CGAffineTransform(rotationAngle: rad(-180))
            rectTransform = rotation.translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        let transformedRect = rect.applying(rectTransform)
        let imageRef = cgImage!.cropping(to: transformedRect)!
        let result = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        //        print("croped Image width and height = \(result.size)")
        return result
    }
}

extension CGContext {
    
    func fill(_ rect: CGRect,
              with mask: CGImage,
              using color: CGColor) {
        
        saveGState()
        defer { restoreGState() }
        
        translateBy(x: 0.0, y: rect.size.height)
        scaleBy(x: 1.0, y: -1.0)
        setBlendMode(.normal)
        
        clip(to: rect, mask: mask)
        
        setFillColor(color)
        fill(rect)
    }
}

extension UIImage {
    
    func filled(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        guard let mask = self.cgImage else { return self }
        
        if #available(iOS 10.0, *) {
            let rendererFormat = UIGraphicsImageRendererFormat()
            rendererFormat.scale = self.scale
            
            let renderer = UIGraphicsImageRenderer(size: rect.size,
                                                   format: rendererFormat)
            return renderer.image { context in
                context.cgContext.fill(rect,
                                       with: mask,
                                       using: color.cgColor)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(rect.size,
                                                   false,
                                                   self.scale)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            
            context.fill(rect,
                         with: mask,
                         using: color.cgColor)
            return UIGraphicsGetImageFromCurrentImageContext() ?? self
        }
    }
    
    func withInset(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)
        
        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)
        
        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
    }
}



final class CalculateHeightAspectRatio {
    
    static let sharedInstance = CalculateHeightAspectRatio()
    
    func getHeight(screenWidth: CGFloat, aspectRatio: AspectRatioResponse?) -> CGFloat {
        let w = aspectRatio?.width ?? 0
        let h = aspectRatio?.height ?? 0
        var frame: CGFloat = 1.0
        if w > h {
            frame = setMultiplier(w: 6.0, h: 4.0, screenWidth: screenWidth)
        }else if w < h{
            frame = setMultiplier(w: 4.0, h: 6.0, screenWidth: screenWidth)
        }else{
            frame = setMultiplier(w: 4.0, h: 4.0, screenWidth: screenWidth)
        }
        return CGFloat(frame)
    }
    
    private func setMultiplier(w: Float,h: Float,screenWidth: CGFloat) -> CGFloat {
        var newFeight: CGFloat = 1.0
        var aspectRatio: CGFloat = 1.0
        if w > h || h > w{ // Landscape or Portrait
            aspectRatio = CGFloat(h / w)
            newFeight = screenWidth * aspectRatio
            
        }else { // Square
            newFeight = screenWidth
        }
        return CGFloat(newFeight)
    }
    
}


