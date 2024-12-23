//
//  UIImage+XW.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import UIKit
import Foundation

public enum GradientDirection {
    case leftToRight
    case topToBottom
    case topLeftToBottomRight
    case botomLeftToTopRight
    case custom(CGPoint, CGPoint)
}

public extension UIImage {
    /// 生成颜色渐变图
    static func gradientImage(with colors: [UIColor],
                              direction: GradientDirection = .leftToRight,
                              size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        defer {
            UIGraphicsEndImageContext()
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map({ $0.cgColor })
        gradientLayer.locations = [0, 1]
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .topLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .botomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case let .custom(startPoint, endPoint):
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
        }
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let contenxt = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        gradientLayer.render(in: contenxt)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return image
    }
    
    /// 截图
    class func screenshot(fromView fv: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(fv.bounds.size, fv.isOpaque, 0.0)
        fv.drawHierarchy(in: fv.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img ?? UIImage()
    }
}
