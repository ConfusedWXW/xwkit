//
//  Data+XW.swift
//  XWKit
//
//  Created by Jay on 2024/3/2.
//

import Foundation

public extension Data {
    init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }

    var bytes: Array<UInt8> {
        return Array(self)
    }

    func toHexString() -> String {
        return bytes.toHexString()
    }
}
