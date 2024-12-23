//
//  TextField.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class TextField: UITextField {
    // 是否允操作
    public var canPerformAction: Bool = true
    // 是否允许粘贴
    public var canPaste: Bool = true
    // 是否允许选择
    public var canSelect: Bool = true
    // 显示允许输入的最大文字长度，默认为 NSUIntegerMax，也即不限制长度。
    public var maximumTextLength: Int = LONG_MAX
    // 按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
    public var shouldCountingNonASCIICharacterAsTwo: Bool = false
    
    // 文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
    public var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open var isWarned: Bool = false {
        didSet {
            if isWarned, originBorderColor == nil, let cgC = self.layer.borderColor {
                // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
                originBorderColor = UIColor(cgColor: cgC)
            }
            
            // 渲染背景色
            if warnedBackgroundColor != nil || warnedBorderColor != nil {
                adjustsTextFieldWarned()
            }
        }
    }
    
    /**
     * 设置按钮点击时的背景色，默认为nil。
     * @warning 不支持带透明度的背景颜色。当设置highlightedBackgroundColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    public var warnedBackgroundColor: UIColor?
    
    /**
     * 设置按钮点击时的边框颜色，默认为nil。
     * @warning 当设置highlightedBorderColor时，会强制把adjustsButtonWhenHighlighted设为NO，避免两者效果冲突。
     * @see adjustsButtonWhenHighlighted
     */
    public var warnedBorderColor: UIColor?
    
    // 修改 placeholder 的颜色，默认是 UIColorPlaceholder。
    public var placeholderColor: UIColor? {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    open override var placeholder: String? {
        didSet {
            super.placeholder = placeholder
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    
    private var warnedBackgroundLayer: CALayer?
    private var originBorderColor: UIColor?
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }


    open func makeUI() {
        layer.masksToBounds = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        warnedBackgroundLayer?.frame = bounds
        warnedBackgroundLayer?.cornerRadius = layer.cornerRadius
        warnedBackgroundLayer?.maskedCorners = layer.maskedCorners
        warnedBackgroundLayer?.backgroundColor = isWarned ? warnedBackgroundColor?.cgColor : UIColor.clear.cgColor
    }
}

extension TextField: UITextFieldDelegate {
//    public func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField.maximumTextLength < LONG_MAX {
//            // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
//            if let markedTextRange = textField.markedTextRange {
//                
//            }
//            
//            if NSMaxRange(range) > textField.text?.count ?? 0 {
//                let range = NSMakeRange(range.location, range.length - (NSMaxRange(range) - (textField.text?.count ?? 0)))
//                if range.length > 0 {
//                    
//                }
//            }
//        }
//        
//        return true
//    }
}


extension TextField {
    func updateAttributedPlaceholderIfNeeded() {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? UIColor(hex: 0x555760)])
    }
    
    func adjustsTextFieldWarned() {
        if let color = warnedBackgroundColor, isWarned {
            if warnedBackgroundLayer == nil {
                warnedBackgroundLayer = CALayer()
                layer.insertSublayer(warnedBackgroundLayer!, at: 0)
            }
        }else{
            warnedBackgroundLayer?.removeFromSuperlayer()
        }
        
        if let color = warnedBorderColor {
            layer.borderWidth =  layer.borderWidth == 0 ? 1 : layer.borderWidth
            layer.borderColor = isWarned ? warnedBorderColor?.cgColor : (originBorderColor ?? .clear).cgColor
        }
    }
}




extension TextField {
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.origin.x += textInsets.left
        bounds.origin.y += textInsets.top
        bounds.size.width -= (textInsets.left + textInsets.right)
        bounds.size.height -= (textInsets.top  + textInsets.bottom)
        return super.textRect(forBounds: bounds)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var bounds = bounds
        bounds.origin.x += textInsets.left
        bounds.origin.y += textInsets.top
        bounds.size.width -= (textInsets.left + textInsets.right)
        bounds.size.height -= (textInsets.top  + textInsets.bottom)
        return super.editingRect(forBounds: bounds)
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    public var leftTextInset: CGFloat {
        get { return textInsets.left }
        set { textInsets.left = newValue }
    }

    public var rightTextInset: CGFloat {
        get { return textInsets.right }
        set { textInsets.right = newValue }
    }

    public var topTextInset: CGFloat {
        get { return textInsets.top }
        set { textInsets.top = newValue }
    }

    public var bottomTextInset: CGFloat {
        get { return textInsets.bottom }
        set { textInsets.bottom = newValue }
    }
}


