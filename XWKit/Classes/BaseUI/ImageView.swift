//
//  ImageView.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class ImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        makeUI()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    open func makeUI() {
        layer.masksToBounds = true
        contentMode = .center

        updateUI()
    }

    open func updateUI() {
        setNeedsDisplay()
    }
}
