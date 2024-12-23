//
//  UIButton+XW.swift
//  XWExtensionKit
//
//  Created by Jay on 2023/11/8.
//

import Foundation
import UIKit


/// 按钮内容样式
public enum XWButtonContentStyle: Int {
    
    /// [默认]左图右字，居中显示
    case leftImageRightTitle = 1
    /// 左字右图，居中显示
    case leftTitleRightImage = 2
    /// 上图下字，居中显示
    case topImageBottomTitle = 3
    /// 上字下图，居中显示
    case topTitleBottomImage = 4
    
    @available(iOS 13.0, *)
    var direction: NSDirectionalRectEdge {
        switch self {
        case .leftImageRightTitle:
            return .leading
        case .leftTitleRightImage:
            return .trailing
        case .topImageBottomTitle:
            return .top
        case .topTitleBottomImage:
            return .bottom
        }
    }
}


public extension UIButton {
    @IBInspectable
    var xwFont: UIFont? {
        get {
            return titleLabel?.font
        }
        set {
            titleLabel?.font = newValue
        }
    }
    
    @IBInspectable
    var imageForDisabled: UIImage? {
        get {
            return image(for: .disabled)
        }
        set {
            setImage(newValue, for: .disabled)
        }
    }
    
    @IBInspectable
    var imageForHighlighted: UIImage? {
        get {
            return image(for: .highlighted)
        }
        set {
            setImage(newValue, for: .highlighted)
        }
    }
    
    @IBInspectable
    var imageForNormal: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            setImage(newValue, for: .normal)
        }
    }
    
    @IBInspectable
    var imageForSelected: UIImage? {
        get {
            return image(for: .selected)
        }
        set {
            setImage(newValue, for: .selected)
        }
    }
    
    @IBInspectable
    var titleColorForDisabled: UIColor? {
        get {
            return titleColor(for: .disabled)
        }
        set {
            setTitleColor(newValue, for: .disabled)
        }
    }
    
    @IBInspectable
    var titleColorForHighlighted: UIColor? {
        get {
            return titleColor(for: .highlighted)
        }
        set {
            setTitleColor(newValue, for: .highlighted)
        }
    }
    
    @IBInspectable
    var titleColorForNormal: UIColor? {
        get {
            return titleColor(for: .normal)
        }
        set {
            setTitleColor(newValue, for: .normal)
        }
    }
    
    @IBInspectable
    var titleColorForSelected: UIColor? {
        get {
            return titleColor(for: .selected)
        }
        set {
            setTitleColor(newValue, for: .selected)
        }
    }
    
    @IBInspectable
    var titleForDisabled: String? {
        get {
            return title(for: .disabled)
        }
        set {
            setTitle(newValue, for: .disabled)
        }
    }
    
    @IBInspectable
    var titleForHighlighted: String? {
        get {
            return title(for: .highlighted)
        }
        set {
            setTitle(newValue, for: .highlighted)
        }
    }
    
    @IBInspectable
    var titleForNormal: String? {
        get {
            return title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }
    
    @IBInspectable
    var titleForSelected: String? {
        get {
            return title(for: .selected)
        }
        set {
            setTitle(newValue, for: .selected)
        }
    }
    
    @IBInspectable
    var backgroundImageNormal: UIImage? {
        get {
            return backgroundImage(for: .normal)
        }
        set {
            setBackgroundImage(newValue, for: .normal)
        }
    }
    
    @IBInspectable
    var backgroundImageSelected: UIImage? {
        get {
            return backgroundImage(for: .selected)
        }
        set {
            setBackgroundImage(newValue, for: .selected)
        }
    }
    
    @IBInspectable
    var backgroundImageDisabled: UIImage? {
        get {
            return backgroundImage(for: .disabled)
        }
        set {
            setBackgroundImage(newValue, for: .disabled)
        }
    }
}


public extension UIButton {
    /// 配置按钮内容样式
    func configContent(style: XWButtonContentStyle, space: CGFloat) {
            resetEdgeInsets()
            
            switch style {
            case .leftImageRightTitle:
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(space), bottom: 0, right: -CGFloat(space))
                self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(space))
                break
            case .leftTitleRightImage:
                self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(space))
                self.setNeedsLayout()
                self.layoutIfNeeded()
                let contentRect = self.contentRect(forBounds: self.bounds)
                let titleSize = self.titleRect(forContentRect: contentRect).size
                let imageSize = self.imageRect(forContentRect: contentRect).size
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: 0, right: imageSize.width)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleSize.width + CGFloat(space), bottom: 0, right: -titleSize.width - CGFloat(space))
                break
            case .topImageBottomTitle:
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
                let contentRect = self.contentRect(forBounds: self.bounds)
                let titleSize = self.titleRect(forContentRect: contentRect).size
                let imageSize = self.imageRect(forContentRect: contentRect).size
                
                let halfWidth = (titleSize.width + imageSize.width) / 2
                let halfHeight = (titleSize.height + imageSize.height) / 2
                
                let topInset = min(halfHeight, titleSize.height)
                let leftInset = (titleSize.width - imageSize.width) > 0 ? (titleSize.width - imageSize.width) / 2 : 0
                let bottomInset = (titleSize.height - imageSize.height) > 0 ? (titleSize.height - imageSize.height) / 2 : 0
                let rightInset = min(halfWidth, titleSize.width)
                
                self.titleEdgeInsets = UIEdgeInsets(top: halfHeight + CGFloat(space), left: -halfWidth, bottom: -halfHeight - CGFloat(space), right: halfWidth)
                self.contentEdgeInsets = UIEdgeInsets(top: -bottomInset, left: leftInset, bottom: topInset + CGFloat(space), right: -rightInset)
                break
            case .topTitleBottomImage:
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
                let contentRect = self.contentRect(forBounds: self.bounds)
                let titleSize = self.titleRect(forContentRect: contentRect).size
                let imageSize = self.imageRect(forContentRect: contentRect).size
                
                let halfWidth = (titleSize.width + imageSize.width) / 2
                let halfHeight = (titleSize.height + imageSize.height) / 2
                
                let topInset = min(halfHeight, titleSize.height)
                let leftInset = (titleSize.width - imageSize.width) > 0 ? (titleSize.width - imageSize.width) / 2 : 0
                let bottomInset = (titleSize.height - imageSize.height) > 0 ? (titleSize.height - imageSize.height) / 2 : 0
                let rightInset = min(halfWidth, titleSize.width)
                
                self.titleEdgeInsets = UIEdgeInsets(top: -halfHeight - CGFloat(space), left: -halfWidth, bottom: halfHeight + CGFloat(space), right: halfWidth)
                self.contentEdgeInsets = UIEdgeInsets(top: topInset + CGFloat(space), left: leftInset, bottom: -bottomInset, right: -rightInset)
                
                break
            }
                
    }
    
    func resetEdgeInsets() {
        self.contentEdgeInsets = UIEdgeInsets.zero
        self.imageEdgeInsets = UIEdgeInsets.zero
        self.titleEdgeInsets = UIEdgeInsets.zero
    }
}
