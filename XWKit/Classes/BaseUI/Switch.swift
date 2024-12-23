//
//  Switch.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class Switch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    open func makeUI() {
    }
}
