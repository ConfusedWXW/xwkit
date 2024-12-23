//
//  CollectionViewCell.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import UIKit

open class CollectionViewCell: UICollectionViewCell {
    
    open func makeUI() {
        self.layer.masksToBounds = true
        updateUI()
    }

    open func updateUI() {
        setNeedsDisplay()
    }
}
