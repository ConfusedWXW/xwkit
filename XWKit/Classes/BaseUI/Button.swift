//
//  Button.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class Button: UIButton {
    public var disabledAlpha: CGFloat = 0.5
    // 是否自动调整disabled时的按钮样式，默认为YES
    // 当值为YES时，按钮disabled时会改变自身的alpha属性为 disabledAlpha
    public var adjustsButtonWhenDisabled: Bool = true
    
    public var highlightedAlpha: CGFloat = 0.7
    // 是否自动调整highlighted时的按钮样式，默认为YES
    // 当值为YES时，按钮highlighted时会改变自身的alpha属性为 highlightedAlpha
    public var adjustsButtonWhenHighlighted: Bool = true
    
    
    /**
     * 设置按钮点击时的背景色，默认为nil。
     * @warning 不支持带透明度的背景颜色。当设置highlightedBackgroundColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    public var highlightedBackgroundColor: UIColor? {
        didSet {
            if highlightedBackgroundColor == nil {
                // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
                self.adjustsButtonWhenHighlighted = false
            }
        }
    }
    
    /**
     * 设置按钮点击时的边框颜色，默认为nil。
     * @warning 当设置highlightedBorderColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    public var highlightedBorderColor: UIColor? {
        didSet {
            if highlightedBorderColor == nil {
                // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
                self.adjustsButtonWhenHighlighted = false
            }
        }
    }
    
    
    
    open override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = isHighlighted
            if isHighlighted, originBorderColor == nil, let cgC = self.layer.borderColor {
                // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
                originBorderColor = UIColor(cgColor: cgC)
            }
            
            // 渲染背景色
            if highlightedBackgroundColor != nil || highlightedBorderColor != nil {
                adjustsButtonHighlighted()
            }
            // 如果此时是disabled，则disabled的样式优先
            if isEnabled == false { return }
            // 自定义highlighted样式
            if adjustsButtonWhenHighlighted {
                alpha = isHighlighted ? highlightedAlpha : 1
            }
        }
    }
    
    
    // 背景渐变颜色
    public var backgroundGradientColors: [UIColor]? {
        didSet {
            updateUI()
        }
    }
    // 渐变方向
    public var gradientDirection: GradientDirection = .leftToRight {
        didSet {
            updateUI()
        }
    }
    // 渐变
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()
    
    
    private var highlightedBackgroundLayer: CALayer?
    private var originBorderColor: UIColor?
    
    
    open override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            if adjustsButtonWhenDisabled {
                self.alpha = isEnabled ? 1 : disabledAlpha
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    // 便捷创建背景渐变按钮
    public convenience init(gradientColors: [UIColor]){
        self.init(frame: .zero)
        self.backgroundGradientColors = gradientColors
    }
    
    

    open func makeUI() {
        // 默认接管highlighted和disabled的表现，去掉系统默认的表现
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        layer.masksToBounds = true
        titleLabel?.lineBreakMode = .byWordWrapping
        
        // 背景渐变
        layer.insertSublayer(gradientLayer, below: titleLabel?.layer)

        updateUI()
    }

    open func updateUI() {
        setNeedsDisplay()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBackgroundGradient()
    }
    
    private func updateBackgroundGradient() {
        if let colors = backgroundGradientColors {
            gradientLayer.colors = colors.map({ $0.cgColor })
            gradientLayer.locations = [0, 1]
            switch gradientDirection {
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
            gradientLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
            gradientLayer.opacity = 1
        }else{
            gradientLayer.opacity = 0
        }
    }
}



extension Button {
    func adjustsButtonHighlighted() {
        if let color = highlightedBackgroundColor {
            if highlightedBackgroundLayer == nil {
                highlightedBackgroundLayer = CALayer()
                layer.insertSublayer(highlightedBackgroundLayer!, above: gradientLayer)
            }
            highlightedBackgroundLayer?.frame = bounds
            highlightedBackgroundLayer?.cornerRadius = layer.cornerRadius
            highlightedBackgroundLayer?.maskedCorners = layer.maskedCorners
            highlightedBackgroundLayer?.backgroundColor = isHighlighted ? highlightedBackgroundColor?.cgColor : UIColor.clear.cgColor
        }
        
        if let color = highlightedBorderColor {
            layer.borderColor = isHighlighted ? highlightedBorderColor?.cgColor : originBorderColor?.cgColor
        }
    }
}
