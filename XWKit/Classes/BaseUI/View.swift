//
//  View.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit
import SnapKit

open class View: UIView {
    
    public convenience init(width: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
    }
    

    public convenience init(height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        snp.makeConstraints { (make) in
            make.height.equalTo(height)
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

    open func makeUI() {
        self.layer.masksToBounds = true
        updateUI()
    }

    open func updateUI() {
        setNeedsDisplay()
    }

    public func getCenter() -> CGPoint {
        return convert(center, from: superview)
    }

}
